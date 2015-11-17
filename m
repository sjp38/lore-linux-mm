Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 765576B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:43:08 -0500 (EST)
Received: by igcph11 with SMTP id ph11so70586465igc.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:43:08 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0090.hostedemail.com. [216.40.44.90])
        by mx.google.com with ESMTP id m7si18677360igj.18.2015.11.16.18.43.07
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 18:43:07 -0800 (PST)
Date: Mon, 16 Nov 2015 21:43:04 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
Message-ID: <20151116214304.6fa42a4e@grimm.local.home>
In-Reply-To: <233209B0-A466-4149-93C6-7173FF0FD4C5@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
	<20151112092923.19ee53dd@gandalf.local.home>
	<5645BFAA.1070004@suse.cz>
	<D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
	<20151113090115.1ad4235b@gandalf.local.home>
	<2F74FF6B-66DC-4BF9-972A-C2F5FFFA979F@gmail.com>
	<5649ACF6.1000704@suse.cz>
	<20151116092501.761f31d7@gandalf.local.home>
	<233209B0-A466-4149-93C6-7173FF0FD4C5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 17 Nov 2015 10:21:47 +0800
yalin wang <yalin.wang2010@gmail.com> wrote:

 =20
> i have not tried ,
> just a question,
> if you print a %s , but don=E2=80=99t call trace_define_field() do define=
 this string in
> __entry ,  how does user space perf tool to get this string info and prin=
t it ?
> i am curious ..
> i can try this when i have time.  and report to you .

Because the print_fmt has nothing to do with the fields. You can have
as your print_fmt as:

	TP_printk("Message =3D %s", "hello dolly!")

And both userspace and the kernel with process that correctly (if I got
string processing working in userspace, which I believe I do). The
string is processed, it's not dependent on TP_STRUCT__entry() unless it
references a field there. Which can also be used too:

	TP_printk("Message =3D %s", __entry->musical ? "Hello dolly!" :
			"Death Trap!")

userspace will see in the entry:

 print_fmt: "Message =3D %s", REC->musical ? "Hello dolly!" : "Death Trap!"

as long as the field "musical" exists, all is well.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
