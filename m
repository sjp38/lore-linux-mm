Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id lATKGcQr003596
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:16:38 -0800
Received: from py-out-1112.google.com (pybp76.prod.google.com [10.34.92.76])
	by zps19.corp.google.com with ESMTP id lATKGaLa029217
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:16:37 -0800
Received: by py-out-1112.google.com with SMTP id p76so4246595pyb
        for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:16:36 -0800 (PST)
Message-ID: <532480950711291216l181b0bej17db6c42067aa832@mail.gmail.com>
Date: Thu, 29 Nov 2007 12:16:36 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file writes
In-Reply-To: <396296481.07368@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071128192957.511EAB8310@localhost> <396296481.07368@ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Due to my faux pas of top posting (see
http://www.zip.com.au/~akpm/linux/patches/stuff/top-posting.txt) I am
resending this email.

On Nov 28, 2007 4:34 PM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> Could you demonstrate the situation? Or if I guess it right, could it
> be fixed by the following patch? (not a nack: If so, your patch could
> also be considered as a general purpose improvement, instead of a bug
> fix.)
>
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 0fca820..62e62e2 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -301,7 +301,7 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
>                          * Someone redirtied the inode while were writing back
>                          * the pages.
>                          */
> -                       redirty_tail(inode);
> +                       requeue_io(inode);
>                 } else if (atomic_read(&inode->i_count)) {
>                         /*
>                          * The inode is clean, inuse
>

By testing the situation I can confirm that the one line patch above
fixes the problem.

I will continue testing some other cases to see if it cause any other
issues but I don't expect it to.
I will post this change for 2.6.24 and list Feng as author. If that's
ok with Feng.

As for the original patch I will resubmit it for 2.6.25 as a general
purpose improvement.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
