Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D6BCA6B0092
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 06:13:22 -0500 (EST)
Received: by wyj26 with SMTP id 26so1520200wyj.14
        for <linux-mm@kvack.org>; Thu, 13 Jan 2011 03:13:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101009003842.GH30846@shell>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
	<20101009003842.GH30846@shell>
Date: Thu, 13 Jan 2011 22:13:20 +1100
Message-ID: <AANLkTimWVfJz7fdJcrs2EVOAxstcK49ATV5SDYqLZUAZ@mail.gmail.com>
Subject: Re: Results of my VFS scaling evaluation.
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Valerie Aurora <vaurora@redhat.com>
Cc: Frank Mayhar <fmayhar@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

On Sat, Oct 9, 2010 at 11:38 AM, Valerie Aurora <vaurora@redhat.com> wrote:
> On Fri, Oct 08, 2010 at 04:32:19PM -0700, Frank Mayhar wrote:
>>
>> Before going into details of the test results, however, I must say that
>> the most striking thing about Nick's work how stable it is. =A0In all of
>
> :D
>
>> the work I've been doing, all the kernels I've built and run and all the
>> tests I've run, I've run into no hangs and only one crash, that in an
>> area that we happen to stress very heavily, for which I posted a patch,
>> available at
>> =A0http://www.kerneltrap.org/mailarchive/linux-fsdevel/2010/9/27/6886943
>> The crash involved the fact that we use cgroups very heavily, and there
>> was an oversight in the new d_set_d_op() routine that failed to clear
>> flags before it set them.
>
> I honestly can't stand the d_set_d_op() patch (testing flags instead
> of d_op->op) because it obfuscates the code in such a way that leads
> directly to this kind of bug. =A0I don't suppose you could test the
> performance effect of that specific patch and see how big of a
> difference it makes?

I'm coming across this message a bit late (due to searching mailing
list for d_set_d_op problems), and I'm sorry I don't think I ever read
it, so I didn't reply.

There are a couple of problems I guess. One is having flags and
ops go out of sync by changing d_op around. I think this one is not
something we want to allow in filesystems and can easily be racy.
The d_set_d_op patch exposed quite a lot of these, and I wish I'd
read this earlier because we've got several of these bugs upstream
now (well arguably they are existing bugs, but anyway they are
crashing testers boxes).

The other potential nasty of this patch is filesystems assigning
d_op directly. This will be exposed pretty quickly because nothing
will work.

As for efficiency -- I am sorry for not including results in the patch.
Now we avoid a load and a couple of branches and a little bit of
icache, which is always nice.

But the biggest motivation for the patch was to fit path walking
dcache footprint in the dentry to a single cache line in the common
case, rather than 2. I think it's worthwhile and there is even a bit
more work to do on dentry shuffling and shrinking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
