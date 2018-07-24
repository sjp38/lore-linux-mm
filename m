Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D82A6B0283
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:50:30 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e3-v6so1923476wrr.8
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:50:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 34-v6sor4228827wrj.84.2018.07.24.03.50.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 03:50:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOm-9aqYLExQZUvfk9ucCoSPoaA67D6ncEDR2+UZBMLhv4-r_A@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
 <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com> <CAOm-9aqYLExQZUvfk9ucCoSPoaA67D6ncEDR2+UZBMLhv4-r_A@mail.gmail.com>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Tue, 24 Jul 2018 12:50:27 +0200
Message-ID: <CADF2uSrL-o9QJ9aXM7+wbX+c6g8Pe2jwp1RFL5qvSBj27MSkHw@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: multipart/alternative; boundary="000000000000b4b3cb0571bc87aa"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--000000000000b4b3cb0571bc87aa
Content-Type: text/plain; charset="UTF-8"

hello guys


excuse me please for dropping in, but I can not ignore the fact that all
this sounds like 99%+ the same
as the issue I am going nuts with for the past 2 months, since I switched
kernels from version 3 to 4.

Please look at the topic `Caching/buffers become useless after some time`.
What I did not mention there
is that cgroups are also mounted and used, but not actively since I have
some scripting issue with setting
them up correctly, but there is active data in
/sys/fs/cgroup/memory/memory.stat so it might be related to
cgroups - I did not think of that until now.

same story here as well, 2> into drop_caches solves the issue temporarily,
for maybe 2-4 days with lots of I/O.

I can however test and play around with cgroups - if one may want to
suggest to disable them I'd gladly
monitor the behavior (please tell me what and how to do it, if necessary).
Also I am curious: could you disable
cgroups as well, just to see whether it helps and is actually associated
with cgroups? my sysctl regarding vm is:

vm.dirty_ratio = 15
vm.dirty_background_ratio = 3
vm.vfs_cache_pressure = 1

I may tell (not for sure) that this issue is less significant since I
lowered these values, previously I had
90/80 on dirty_ratio and dirty_background_ratio, not sure about the cache
pressue any more.
Still there is lots of ram unallocated, usually at least half, mostly even
more totally unused, the hosts
have 64GB of RAM as well.

I hope this is kinda related, so we can work together on pinpointing this,
that issue is not going away
for me and causes lots of headache slowing down my entire business.

2018-07-24 12:05 GMT+02:00 Bruce Merry <bmerry@ska.ac.za>:

> On 18 July 2018 at 19:40, Bruce Merry <bmerry@ska.ac.za> wrote:
> >> Yes, very easy to produce zombies, though I don't think kernel
> >> provides any way to tell how many zombies exist on the system.
> >>
> >> To create a zombie, first create a memcg node, enter that memcg,
> >> create a tmpfs file of few KiBs, exit the memcg and rmdir the memcg.
> >> That memcg will be a zombie until you delete that tmpfs file.
> >
> > Thanks, that makes sense. I'll see if I can reproduce the issue.
>
> Hi
>
> I've had some time to experiment with this issue, and I've now got a
> way to reproduce it fairly reliably, including with a stock 4.17.8
> kernel. However, it's very phase-of-the-moon stuff, and even
> apparently trivial changes (like switching the order in which the
> files are statted) makes the issue disappear.
>
> To reproduce:
> 1. Start cadvisor running. I use the 0.30.2 binary from Github, and
> run it with sudo ./cadvisor-0.30.2 --logtostderr=true
> 2. Run the Python 3 script below, which repeatedly creates a cgroup,
> enters it, stats some files in it, and leaves it again (and removes
> it). It takes a few minutes to run.
> 3. time cat /sys/fs/cgroup/memory/memory.stat. It now takes about 20ms
> for me.
> 4. sudo sysctl vm.drop_caches=2
> 5. time cat /sys/fs/cgroup/memory/memory.stat. It is back to 1-2ms.
>
> I've also added some code to memcg_stat_show to report the number of
> cgroups in the hierarchy (iterations in for_each_mem_cgroup_tree).
> Running the script increases it from ~700 to ~41000. The script
> iterates 250,000 times, so only some fraction of the cgroups become
> zombies.
>
> I also tried the suggestion of force_empty: it makes the problem go
> away, but is also very, very slow (about 0.5s per iteration), and
> given the sensitivity of the test to small changes I don't know how
> meaningful that is.
>
> Reproduction code (if you have tqdm installed you get a nice progress
> bar, but not required). Hopefully Gmail doesn't do any format
> mangling:
>
>
> #!/usr/bin/env python3
> import os
>
> try:
>     from tqdm import trange as range
> except ImportError:
>     pass
>
>
> def clean():
>     try:
>         os.rmdir(name)
>     except FileNotFoundError:
>         pass
>
>
> def move_to(cgroup):
>     with open(cgroup + '/tasks', 'w') as f:
>         print(pid, file=f)
>
>
> pid = os.getpid()
> os.chdir('/sys/fs/cgroup/memory')
> name = 'dummy'
> N = 250000
> clean()
> try:
>     for i in range(N):
>         os.mkdir(name)
>         move_to(name)
>         for filename in ['memory.stat', 'memory.swappiness']:
>             os.stat(os.path.join(name, filename))
>         move_to('user.slice')
>         os.rmdir(name)
> finally:
>     move_to('user.slice')
>     clean()
>
>
> Regards
> Bruce
> --
> Bruce Merry
> Senior Science Processing Developer
> SKA South Africa
>
>

--000000000000b4b3cb0571bc87aa
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>hello guys</div><div><br></div><div><br></div><div>ex=
cuse me please for dropping in, but I can not ignore the fact that all this=
 sounds like 99%+ the same</div><div>as the issue I am going nuts with for =
the past 2 months, since I switched kernels from version 3 to 4.</div><div>=
<br></div><div>Please look at the topic `Caching/buffers become useless aft=
er some time`. What I did not mention there</div><div>is that cgroups are a=
lso mounted and used, but not actively since I have some scripting issue wi=
th setting</div><div>them up correctly, but there is active data in /sys/fs=
/cgroup/memory/memory.stat so it might be related to</div><div>cgroups - I =
did not think of that until now.</div><div><br></div><div>same story here a=
s well, 2&gt; into drop_caches solves the issue temporarily, for maybe 2-4 =
days with lots of I/O.<br></div><div><br></div><div>I can however test and =
play around with cgroups - if one may want to suggest to disable them I&#39=
;d gladly</div><div>monitor the behavior (please tell me what and how to do=
 it, if necessary). Also I am curious: could you disable</div><div>cgroups =
as well, just to see whether it helps and is actually associated with cgrou=
ps? my sysctl regarding vm is:</div><div><br></div><div>vm.dirty_ratio =3D =
15<br>vm.dirty_background_ratio =3D 3<br>vm.vfs_cache_pressure =3D 1</div><=
div><br></div><div>I may tell (not for sure) that this issue is less signif=
icant since I lowered these values, previously I had</div><div>90/80 on dir=
ty_ratio and dirty_background_ratio, not sure about the cache pressue any m=
ore.</div><div>Still there is lots of ram unallocated, usually at least hal=
f, mostly even more totally unused, the hosts</div><div>have 64GB of RAM as=
 well.</div><div><br></div><div>I hope this is kinda related, so we can wor=
k together on pinpointing this, that issue is not going away</div><div>for =
me and causes lots of headache slowing down my entire business.<br></div></=
div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2018-07-24 12=
:05 GMT+02:00 Bruce Merry <span dir=3D"ltr">&lt;<a href=3D"mailto:bmerry@sk=
a.ac.za" target=3D"_blank">bmerry@ska.ac.za</a>&gt;</span>:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex"><span class=3D"">On 18 July 2018 at 19:40, Bruce Merry &=
lt;<a href=3D"mailto:bmerry@ska.ac.za">bmerry@ska.ac.za</a>&gt; wrote:<br>
&gt;&gt; Yes, very easy to produce zombies, though I don&#39;t think kernel=
<br>
&gt;&gt; provides any way to tell how many zombies exist on the system.<br>
&gt;&gt;<br>
&gt;&gt; To create a zombie, first create a memcg node, enter that memcg,<b=
r>
&gt;&gt; create a tmpfs file of few KiBs, exit the memcg and rmdir the memc=
g.<br>
&gt;&gt; That memcg will be a zombie until you delete that tmpfs file.<br>
&gt;<br>
&gt; Thanks, that makes sense. I&#39;ll see if I can reproduce the issue.<b=
r>
<br>
</span>Hi<br>
<br>
I&#39;ve had some time to experiment with this issue, and I&#39;ve now got =
a<br>
way to reproduce it fairly reliably, including with a stock 4.17.8<br>
kernel. However, it&#39;s very phase-of-the-moon stuff, and even<br>
apparently trivial changes (like switching the order in which the<br>
files are statted) makes the issue disappear.<br>
<br>
To reproduce:<br>
1. Start cadvisor running. I use the 0.30.2 binary from Github, and<br>
run it with sudo ./cadvisor-0.30.2 --logtostderr=3Dtrue<br>
2. Run the Python 3 script below, which repeatedly creates a cgroup,<br>
enters it, stats some files in it, and leaves it again (and removes<br>
it). It takes a few minutes to run.<br>
3. time cat /sys/fs/cgroup/memory/memory.<wbr>stat. It now takes about 20ms=
 for me.<br>
4. sudo sysctl vm.drop_caches=3D2<br>
5. time cat /sys/fs/cgroup/memory/memory.<wbr>stat. It is back to 1-2ms.<br=
>
<br>
I&#39;ve also added some code to memcg_stat_show to report the number of<br=
>
cgroups in the hierarchy (iterations in for_each_mem_cgroup_tree).<br>
Running the script increases it from ~700 to ~41000. The script<br>
iterates 250,000 times, so only some fraction of the cgroups become<br>
zombies.<br>
<br>
I also tried the suggestion of force_empty: it makes the problem go<br>
away, but is also very, very slow (about 0.5s per iteration), and<br>
given the sensitivity of the test to small changes I don&#39;t know how<br>
meaningful that is.<br>
<br>
Reproduction code (if you have tqdm installed you get a nice progress<br>
bar, but not required). Hopefully Gmail doesn&#39;t do any format<br>
mangling:<br>
<br>
<br>
#!/usr/bin/env python3<br>
import os<br>
<br>
try:<br>
=C2=A0 =C2=A0 from tqdm import trange as range<br>
except ImportError:<br>
=C2=A0 =C2=A0 pass<br>
<br>
<br>
def clean():<br>
=C2=A0 =C2=A0 try:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 os.rmdir(name)<br>
=C2=A0 =C2=A0 except FileNotFoundError:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 pass<br>
<br>
<br>
def move_to(cgroup):<br>
=C2=A0 =C2=A0 with open(cgroup + &#39;/tasks&#39;, &#39;w&#39;) as f:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 print(pid, file=3Df)<br>
<br>
<br>
pid =3D os.getpid()<br>
os.chdir(&#39;/sys/fs/cgroup/<wbr>memory&#39;)<br>
name =3D &#39;dummy&#39;<br>
N =3D 250000<br>
clean()<br>
try:<br>
=C2=A0 =C2=A0 for i in range(N):<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 os.mkdir(name)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 move_to(name)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for filename in [&#39;memory.stat&#39;, &#39;me=
mory.swappiness&#39;]:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 os.stat(os.path.join(name, filena=
me))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 move_to(&#39;user.slice&#39;)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 os.rmdir(name)<br>
finally:<br>
=C2=A0 =C2=A0 move_to(&#39;user.slice&#39;)<br>
=C2=A0 =C2=A0 clean()<br>
<br>
<br>
Regards<br>
<div class=3D"HOEnZb"><div class=3D"h5">Bruce<br>
-- <br>
Bruce Merry<br>
Senior Science Processing Developer<br>
SKA South Africa<br>
<br>
</div></div></blockquote></div><br></div>

--000000000000b4b3cb0571bc87aa--
