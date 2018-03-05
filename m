Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 782CC6B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 07:17:47 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q195so15945293ioe.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 04:17:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c5sor4606094iti.117.2018.03.05.04.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 04:17:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1520245563-8444-8-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org> <1520245563-8444-8-git-send-email-joro@8bytes.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Mar 2018 04:17:45 -0800
Message-ID: <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Content-Type: multipart/alternative; boundary="001a113a427e4596020566a950bb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

--001a113a427e4596020566a950bb
Content-Type: text/plain; charset="UTF-8"

[ On mobile, sorry for html ]

On Mar 5, 2018 02:26, "Joerg Roedel" <joro@8bytes.org> wrote:

From: Joerg Roedel <jroedel@suse.de>

Restoring the segments can cause exceptions that need to be
handled. With PTI enabled, we still need to be on kernel cr3
when the exception happens. For the cr3-switch we need
at least one integer scratch register, so we can't switch
with the user integer registers already loaded.


This fundamentally seems wrong.

The things is, we *know* that we will restore two segment registers with
the user cr3 already loaded: CS and SS get restored with the final iret.

And yes, the final iret can fault due to CS/SS no longer being valid,
either because of ptrace or because the ldt was changed.

So making it be a "rule" that segment registers be restored with the kernel
cr3 active seems bogus. It just means that you're making a rule that cannot
possibly be generic.

So has this been tested with

 - single-stepping through sysenter

   This takes a DB fault in the first kernel instruction. We're in kernel
mode, but with user cr3.

 - ptracing and setting CS/SS to something bad

   That should test the "exception on iret" case - again in kernel mode,
but with user cr3 restored for the return.

I didn't look closely at the whole series, so maybe this is all fine. I
mainly reacted to the "With PTI enabled, we still need to be on kernel cr3
when the exception happens" part of the explanation..

      Linus

--001a113a427e4596020566a950bb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">[ On mobile, sorry for html ]<br><div class=3D"gmail_extr=
a" dir=3D"auto"><br><div class=3D"gmail_quote">On Mar 5, 2018 02:26, &quot;=
Joerg Roedel&quot; &lt;<a href=3D"mailto:joro@8bytes.org">joro@8bytes.org</=
a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">From: Joerg =
Roedel &lt;<a href=3D"mailto:jroedel@suse.de">jroedel@suse.de</a>&gt;<br>
<br>
Restoring the segments can cause exceptions that need to be<br>
handled. With PTI enabled, we still need to be on kernel cr3<br>
when the exception happens. For the cr3-switch we need<br>
at least one integer scratch register, so we can&#39;t switch<br>
with the user integer registers already loaded.<br></blockquote></div></div=
><div dir=3D"auto"><br></div><div dir=3D"auto">This fundamentally seems wro=
ng.</div><div dir=3D"auto"><br></div><div dir=3D"auto">The things is, we *k=
now* that we will restore two segment registers with the user cr3 already l=
oaded: CS and SS get restored with the final iret.</div><div dir=3D"auto"><=
br></div><div dir=3D"auto">And yes, the final iret can fault due to CS/SS n=
o longer being valid, either because of ptrace or because the ldt was chang=
ed.</div><div dir=3D"auto"><br></div><div dir=3D"auto">So making it be a &q=
uot;rule&quot; that segment registers be restored with the kernel cr3 activ=
e seems bogus. It just means that you&#39;re making a rule that cannot poss=
ibly be generic.</div><div dir=3D"auto"><br></div><div dir=3D"auto">So has =
this been tested with</div><div dir=3D"auto"><br></div><div dir=3D"auto">=
=C2=A0- single-stepping through sysenter</div><div dir=3D"auto"><br></div><=
div dir=3D"auto">=C2=A0 =C2=A0This takes a DB fault in the first kernel ins=
truction. We&#39;re in kernel mode, but with user cr3.</div><div dir=3D"aut=
o"><br></div><div dir=3D"auto">=C2=A0- ptracing and setting CS/SS to someth=
ing bad</div><div dir=3D"auto"><br></div><div dir=3D"auto">=C2=A0 =C2=A0Tha=
t should test the &quot;exception on iret&quot; case - again in kernel mode=
, but with user cr3 restored for the return.</div><div dir=3D"auto"><br></d=
iv><div dir=3D"auto">I didn&#39;t look closely at the whole series, so mayb=
e this is all fine. I mainly reacted to the &quot;<span style=3D"font-famil=
y:sans-serif">With PTI enabled, we still need to be on kernel cr3</span></d=
iv><div dir=3D"auto"><span style=3D"font-family:sans-serif">when the except=
ion happens&quot; part of the explanation..</span><br></div><div dir=3D"aut=
o"><span style=3D"font-family:sans-serif"><br></span></div><div dir=3D"auto=
"><span style=3D"font-family:sans-serif">=C2=A0 =C2=A0 =C2=A0 Linus</span><=
/div><div dir=3D"auto"><br></div><div class=3D"gmail_extra" dir=3D"auto"><d=
iv class=3D"gmail_quote"><blockquote class=3D"quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex"></blockquote></div></div>=
</div>

--001a113a427e4596020566a950bb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
