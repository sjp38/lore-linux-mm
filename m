Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFF3A6B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 07:58:46 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n184so715808359oig.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 04:58:46 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0080.outbound.protection.outlook.com. [104.47.1.80])
        by mx.google.com with ESMTPS id m20si14235092otd.277.2016.12.08.04.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 04:58:45 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id g23so216119249wme.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 04:58:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ef9a07bc-e0d9-46ed-8898-7db6b1d4cb9f@suse.cz>
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
 <52a0d9c3-5c9a-d207-4cbc-a6df27ba6a9c@suse.cz> <CACKey4yB_qXdRn1=qNu65GA0ER-DL+DEqhP9QRGkWX79jVao8g@mail.gmail.com>
 <ef9a07bc-e0d9-46ed-8898-7db6b1d4cb9f@suse.cz>
From: Federico Reghenzani <federico.reghenzani@polimi.it>
Date: Thu, 8 Dec 2016 13:58:19 +0100
Message-ID: <CACKey4xPsu5_-YcYNWv3xV-9s7heedOkURyOM8m4PJc=4EVQ2Q@mail.gmail.com>
Subject: Re: mlockall() with pid parameter
Content-Type: multipart/alternative; boundary="001a114d46b8535454054325329c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, kirill@shutemov.name
Cc: linux-mm@kvack.org

--001a114d46b8535454054325329c
Content-Type: text/plain; charset="UTF-8"

Ok, these solutions are feasible but not very comfortable.

I'll explain better what I'm going to do. I'm a developer of Barbeque Open
<http://bosp.dei.polimi.it/>
Source Project <http://bosp.dei.polimi.it/> that is run-time resource
manager. It is basically composed of a
daemon (barbeque) and a library (rtlib) linked with user applications. A
user
starts a process linked with rtlib that exchanges some information with
Barbeque
(e.g. it requests a performance goal). Barbeque is in charge of the
assignment
of resources trying to maintain the performance goals of all applications
and predefined system requirements (e.g. temperatures and power
consumption).

When processes start, Barbeque tunes several parameters at run-time: create
and
set CGroups, select cpu governors and frequency, etc. In the case of a
real-time
process it decides the scheduling policy, the scheduling parameters, etc.

Barbeque runs with root privileges, thus it has the CAP_SYS_NICE capability
to enforce a RT scheduling policy on applications.

The idea is to give to Barbeque the possibility to dinamically select if
enforcing mlockall() or not for RT tasks, according to the available memory
resources. I can do this using a sort of synchronization mechanism: Barbeque
sets limits of the process and signal the rtlib to execute the mlockall()
or the
munlockall(), but I think it would be better to have a syscall that
Barbeque can
call directly without interfering with process execution.

Yesterday I rapidly read the code of mlockall() and relative functions and I
think that in order to add a pid parameter is maybe sufficient to convert
the
pid into a task struct and replace `current` with it. Probably, it will not
be so easy. Tomorrow I'm going to read the code more in details and check if
the implementation is actually easy and does not involve too much
refactoring in
the present code.


Thank you,
Federico

2016-12-07 21:01 GMT+01:00 Vlastimil Babka <vbabka@suse.cz>:

> On 12/07/2016 05:33 PM, Federico Reghenzani wrote:
> >
> >
> > 2016-12-07 17:21 GMT+01:00 Vlastimil Babka <vbabka@suse.cz
> > <mailto:vbabka@suse.cz>>:
> >
> >     On 12/07/2016 04:39 PM, Federico Reghenzani wrote:
> >     > Hello,
> >     >
> >     > I'm working on Real-Time applications in Linux. `mlockall()` is a
> >     > typical syscall used in RT processes in order to avoid page faults.
> >     > However, the use of this syscall is strongly limited by ulimits, so
> >     > basically all RT processes that want to call `mlockall()` have to
> be
> >     > executed with root privileges.
> >
> >     Is it not possible to change the ulimits with e.g. prlimit?
> >
> >
> > Yes, but it requires a synchronization between non-root process and root
> > process.
> > Because the root process has to change the limits before the non-root
> > process executes the mlockall().
>
> Would it work if you did that between fork() and exec()? If you can
> spawn them like this, that is.
>
> > Just to provide an example, another syscall used in RT tasks is the
> > sched_setscheduler() that also suffers
> > the limitation of ulimits, but it accepts the pid so the scheduling
> > policy can be enforced by a root process to
> > any other process.
> >
> >
> >
> >     > What I would like to have is a syscall that accept a "pid", so a
> process
> >     > spawned by root would be able to enforce the memory locking to
> other
> >     > non-root processes. The prototypes would be:
> >     >
> >     > int mlockall(int flags, pid_t pid);
> >     > int munlockall(pid_t pid);
> >     >
> >     > I checked the source code and it seems to me quite easy to add this
> >     > syscall variant.
> >     >
> >     > I'm writing here to have a feedback before starting to edit the
> code. Do
> >     > you think that this is a good approach?
> >     >
> >     >
> >     > Thank you,
> >     > Federico
> >     >
> >     > --
> >     > *Federico Reghenzani*
> >     > PhD Candidate
> >     > Politecnico di Milano
> >     > Dipartimento di Elettronica, Informazione e Bioingegneria
> >     >
> >
> >
> >
> >
> > --
> > *Federico Reghenzani*
> > PhD Candidate
> > Politecnico di Milano
> > Dipartimento di Elettronica, Informazione e Bioingegneria
> >
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
*Federico Reghenzani*
PhD Candidate
Politecnico di Milano
Dipartimento di Elettronica, Informazione e Bioingegneria

--001a114d46b8535454054325329c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Ok, these solutions are feasible but not very comfort=
able.</div><div><br></div><div>I&#39;ll explain better what I&#39;m going t=
o do. I&#39;m a developer of <a href=3D"http://bosp.dei.polimi.it/">Barbequ=
e Open</a></div><div><a href=3D"http://bosp.dei.polimi.it/">Source Project<=
/a> that is run-time resource manager. It is basically composed of a</div><=
div>daemon (barbeque) and a library (rtlib) linked with user applications. =
A user=C2=A0</div><div>starts a process linked with rtlib that exchanges so=
me information with Barbeque</div><div>(e.g. it requests a performance goal=
). Barbeque is in charge of the assignment</div><div>of resources trying to=
 maintain the performance goals of all applications</div><div>and predefine=
d system requirements (e.g. temperatures and power consumption).</div><div>=
<br></div><div>When processes start, Barbeque tunes several parameters at r=
un-time: create and</div><div>set CGroups, select cpu governors and frequen=
cy, etc. In the case of a real-time</div><div>process it decides the schedu=
ling policy, the scheduling parameters, etc.</div><div><br></div><div>Barbe=
que runs with root privileges, thus it has the CAP_SYS_NICE capability</div=
><div>to enforce a RT scheduling policy on applications.</div><div><br></di=
v><div>The idea is to give to Barbeque the possibility to dinamically selec=
t if</div><div>enforcing mlockall() or not for RT tasks, according to the a=
vailable memory</div><div>resources. I can do this using a sort of synchron=
ization mechanism: Barbeque</div><div>sets limits of the process and signal=
 the rtlib to execute the mlockall() or the</div><div>munlockall(), but I t=
hink it would be better to have a syscall that Barbeque can</div><div>call =
directly without interfering with process execution.</div><div><br></div><d=
iv>Yesterday I rapidly read the code of mlockall() and relative functions a=
nd I</div><div>think that in order to add a pid parameter is maybe sufficie=
nt to convert the</div><div>pid into a task struct and replace `current` wi=
th it. Probably, it will not=C2=A0</div><div>be so easy. Tomorrow I&#39;m g=
oing to read the code more in details and check if</div><div>the implementa=
tion is actually easy and does not involve too much refactoring in</div><di=
v>the present code.</div><div><br></div><div><br></div><div>Thank you,</div=
><div>Federico</div><div class=3D"gmail_extra"><br><div class=3D"gmail_quot=
e">2016-12-07 21:01 GMT+01:00 Vlastimil Babka <span dir=3D"ltr">&lt;<a href=
=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;</span>:=
<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex"><span class=3D"">On 12/07/2016 05:33 PM,=
 Federico Reghenzani wrote:<br>
&gt;<br>
&gt;<br>
&gt; 2016-12-07 17:21 GMT+01:00 Vlastimil Babka &lt;<a href=3D"mailto:vbabk=
a@suse.cz">vbabka@suse.cz</a><br>
</span>&gt; &lt;mailto:<a href=3D"mailto:vbabka@suse.cz">vbabka@suse.cz</a>=
&gt;&gt;:<br>
<span class=3D"">&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0On 12/07/2016 04:39 PM, Federico Reghenzani wrote:<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Hello,<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; I&#39;m working on Real-Time applications in L=
inux. `mlockall()` is a<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; typical syscall used in RT processes in order =
to avoid page faults.<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; However, the use of this syscall is strongly l=
imited by ulimits, so<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; basically all RT processes that want to call `=
mlockall()` have to be<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; executed with root privileges.<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0Is it not possible to change the ulimits with e.g. =
prlimit?<br>
&gt;<br>
&gt;<br>
&gt; Yes, but it requires a synchronization between non-root process and ro=
ot<br>
&gt; process.<br>
&gt; Because the root process has to change the limits before the non-root<=
br>
&gt; process executes the mlockall().<br>
<br>
</span>Would it work if you did that between fork() and exec()? If you can<=
br>
spawn them like this, that is.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; Just to provide an example, another syscall used in RT tasks is the<br=
>
&gt; sched_setscheduler() that also suffers<br>
&gt; the limitation of ulimits, but it accepts the pid so the scheduling<br=
>
&gt; policy can be enforced by a root process to<br>
&gt; any other process.<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; What I would like to have is a syscall that ac=
cept a &quot;pid&quot;, so a process<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; spawned by root would be able to enforce the m=
emory locking to other<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; non-root processes. The prototypes would be:<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; int mlockall(int flags, pid_t pid);<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; int munlockall(pid_t pid);<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; I checked the source code and it seems to me q=
uite easy to add this<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; syscall variant.<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; I&#39;m writing here to have a feedback before=
 starting to edit the code. Do<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; you think that this is a good approach?<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Thank you,<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Federico<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; --<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; *Federico Reghenzani*<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; PhD Candidate<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Politecnico di Milano<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt; Dipartimento di Elettronica, Informazione e Bi=
oingegneria<br>
&gt;=C2=A0 =C2=A0 =C2=A0&gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; --<br>
&gt; *Federico Reghenzani*<br>
&gt; PhD Candidate<br>
&gt; Politecnico di Milano<br>
&gt; Dipartimento di Elettronica, Informazione e Bioingegneria<br>
&gt;<br>
<br>
--<br>
</div></div><div class=3D"HOEnZb"><div class=3D"h5">To unsubscribe, send a =
message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>=
<div class=3D"gmail_signature" data-smartmail=3D"gmail_signature"><div dir=
=3D"ltr"><b>Federico Reghenzani</b><div><font size=3D"1">PhD Candidate</fon=
t></div><div><font size=3D"1">Politecnico di Milano</font></div><div><font =
size=3D"1">Dipartimento di Elettronica, Informazione e Bioingegneria</font>=
</div><div><br></div></div></div>
</div></div>

--001a114d46b8535454054325329c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
