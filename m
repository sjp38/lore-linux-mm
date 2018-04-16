Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFF66B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:24:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o2-v6so3039237plk.0
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:24:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h2si2034340pfb.111.2018.04.16.12.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 12:24:34 -0700 (PDT)
Date: Mon, 16 Apr 2018 15:24:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416152429.529e3cba@gandalf.local.home>
In-Reply-To: <CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
References: <20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
	<20180416142653.0f017647@gandalf.local.home>
	<CA+55aFzggPvS2MwFnKfXs6yHUQrbrJH7uyY4=znwetcdEXmZrw@mail.gmail.com>
	<20180416144117.5757ee70@gandalf.local.home>
	<CA+55aFyyZ7KmXbEa151JP287vypJAkxugW17YC7Q1B9=TnyHkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 11:52:48 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 16, 2018 at 11:41 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> >I never said the second
> > bug fix should not have been backported. I even said that the first bug
> > "didn't go far enough".  
> 
> You're still not getting it.
> 
> The "didn't go far enough" means that the bug fix is *BUGGY*. It needs
> to be reverted.

It wasn't reverted. Look at the code in question.

Commit d63c7dd5bcb

+++ b/drivers/scsi/ipr.c
@@ -4003,13 +4003,12 @@ static ssize_t ipr_store_update_fw(struct device *dev,
 	struct ipr_sglist *sglist;
 	char fname[100];
 	char *src;
-	int len, result, dnld_size;
+	int result, dnld_size;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EACCES;
 
-	len = snprintf(fname, 99, "%s", buf);
-	fname[len-1] = '\0';
+	snprintf(fname, sizeof(fname), "%s", buf);
 
 	if (request_firmware(&fw_entry, fname, &ioa_cfg->pdev->dev)) {
 		dev_err(&ioa_cfg->pdev->dev, "Firmware file %s not found\n", fname);


The bug is that len returned by snprintf() can be much larger than 100.
That fname[len-1] = '\0' can allow a user to decide where to write
zeros.

That patch never got reverted in mainline. It was fixed with this:

Commit 21b81716c6bf

--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -4002,6 +4002,7 @@ static ssize_t ipr_store_update_fw(struct device *dev,
        struct ipr_sglist *sglist;
        char fname[100];
        char *src;
+       char *endline;
        int result, dnld_size;
 
        if (!capable(CAP_SYS_ADMIN))
@@ -4009,6 +4010,10 @@ static ssize_t ipr_store_update_fw(struct device *dev,
 
        snprintf(fname, sizeof(fname), "%s", buf);
 
+       endline = strchr(fname, '\n');
+       if (endline)
+               *endline = '\0';
+
        if (request_firmware(&fw_entry, fname, &ioa_cfg->pdev->dev)) {
                dev_err(&ioa_cfg->pdev->dev, "Firmware file %s not found\n", fname);
                return -EIO;

> 
> > I hope the answer was not to revert the bug and put back the possible
> > bad memory access in to keep API.  
> 
> But that very must *IS* the answer. If there isn't a fix for the ABI
> breakage, then the first bugfix needs to be reverted.

It wasn't reverted and that was my point. It just wasn't a complete
fix. And I'm saying that once the API breakage became apparent, the
second fix should have been backported as well.

I'm not saying that we should allow API breakage to fix a critical bug.
I'm saying that the API breakage was really a secondary bug that needed
to be addressed. My point is the first fix was NOT reverted!


> 
> Really. There is no such thing as "but the fix was more important than
> the bug it introduced".

I'm not saying that.

> 
> This is why we started with the whole "actively revert things that
> introduce regressions". Because people always kept claiming that "but
> but I fixed a worse bug, and it's better to fix the worse bug even if
> it then introduces another problem, because the other problem is
> lesser".
> 
> NO.

Right, but the fix to the API was also trivial. I don't understand why
you are arguing with me. I agree with you. I'm talking about this
specific instance. Where a bug was fixed, and the API breakage was
another fix that needed to be backported.

Are you saying if code could allow userspace to write zeros anywhere in
memory, that we should keep it to allow API compatibility?

> 
> We're better off making *no* progress, than making "unsteady progress".
> 
> Really. Seriously.
> 
> If you cannot fix a bug without introducing another one, don't do it.
> Don't do kernel development.

Um, I think that's impossible. As the example shows. Not many people
would have caught the original fix would caused another bug. That
requirement would pretty much keep everyone from ever doing any kernel
development.

> 
> The whole mentality you show is NOT ACCEPTABLE.
> 
> So the *only* answer is: "fix the bug _and_ keep the API".  There is
> no other choice.

I agree. But that that wasn't the question.

> 
> The whole "I fixed one problem but introduced another" is not how we
> work. You should damn well know that. There are no excuses.
> 
> And yes, sometimes that means jumping through hoops. But that's what
> it takes to keep users happy.


I'm talking about the given example of a simple memory bug that caused
a very subtle breakage of API, which had another trivial fix that
should be backported. I'm not sure that's what you were talking about.

-- Steve
