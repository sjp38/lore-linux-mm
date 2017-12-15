Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 819EF6B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:09:26 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id h200so12929055itb.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 22:09:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 65sor1692303iop.360.2017.12.14.22.09.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 22:09:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 14 Dec 2017 22:09:24 -0800
Message-ID: <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: multipart/alternative; boundary="001a113f8db6aa4b4405605ad774"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, tglx@linutronix.de, x86@kernel.org, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

--001a113f8db6aa4b4405605ad774
Content-Type: text/plain; charset="UTF-8"

On Dec 14, 2017 21:04, "Dave Hansen" <dave.hansen@intel.com> wrote:

On 12/14/2017 12:54 PM, Peter Zijlstra wrote:
>> That short-circuits the page fault pretty quickly.  So, basically, the
>> rule is: if the hardware says you tripped over pkey permissions, you
>> die.  We don't try to do anything to the underlying page *before* saying
>> that you die.
> That only works when you trip the fault from hardware. Not if you do a
> software fault using gup().
>
> AFAIK __get_user_pages(FOLL_FORCE|FOLL_WRITE|FOLL_GET) will loop
> indefinitely on the case I described.

So, the underlying bug here is that we now a get_user_pages_remote() and
then go ahead and do the p*_access_permitted() checks against the
current PKRU.  This was introduced recently with the addition of the new
p??_access_permitted() calls.


Can we please just undo that broken crap instead of trying to "fix" it?

It was wrong. We absolutely do not want to complicate the gup path.

Let's fet rid of those broken p??_access_permited() things.

Please.

         Linus

--001a113f8db6aa4b4405605ad774
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Dec 14, 2017 21:04, &quot;Dave Hansen&quot; &lt;<a href=3D"mai=
lto:dave.hansen@intel.com">dave.hansen@intel.com</a>&gt; wrote:<br type=3D"=
attribution"><blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border-=
left:1px #ccc solid;padding-left:1ex"><div class=3D"quoted-text">On 12/14/2=
017 12:54 PM, Peter Zijlstra wrote:<br>
&gt;&gt; That short-circuits the page fault pretty quickly.=C2=A0 So, basic=
ally, the<br>
&gt;&gt; rule is: if the hardware says you tripped over pkey permissions, y=
ou<br>
&gt;&gt; die.=C2=A0 We don&#39;t try to do anything to the underlying page =
*before* saying<br>
&gt;&gt; that you die.<br>
&gt; That only works when you trip the fault from hardware. Not if you do a=
<br>
&gt; software fault using gup().<br>
&gt;<br>
&gt; AFAIK __get_user_pages(FOLL_FORCE|<wbr>FOLL_WRITE|FOLL_GET) will loop<=
br>
&gt; indefinitely on the case I described.<br>
<br>
</div>So, the underlying bug here is that we now a get_user_pages_remote() =
and<br>
then go ahead and do the p*_access_permitted() checks against the<br>
current PKRU.=C2=A0 This was introduced recently with the addition of the n=
ew<br>
p??_access_permitted() calls.<br></blockquote></div></div></div><div dir=3D=
"auto"><br></div><div dir=3D"auto">Can we please just undo that broken crap=
 instead of trying to &quot;fix&quot; it?</div><div dir=3D"auto"><br></div>=
<div dir=3D"auto">It was wrong. We absolutely do not want to complicate the=
 gup path.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"auto">Let&#39=
;s fet rid of those broken p??_access_permited() things.</div><div dir=3D"a=
uto"><br></div><div dir=3D"auto">Please.</div><div dir=3D"auto"><br></div><=
div dir=3D"auto">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linus</div><div dir=3D"a=
uto"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote clas=
s=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex"></blockquote></div></div></div><div dir=3D"auto"></div></div>

--001a113f8db6aa4b4405605ad774--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
