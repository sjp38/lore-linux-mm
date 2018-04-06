Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1381F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 07:36:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u13so635766wre.1
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 04:36:07 -0700 (PDT)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id t15si7475507wrb.190.2018.04.06.04.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 06 Apr 2018 04:36:05 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:35:45 +0100
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Message-ID: <20180406123545.24953eb4@alans-desktop>
In-Reply-To: <20180405211945-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
	<20180405045231-mutt-send-email-mst@kernel.org>
	<CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
	<20180405171009-mutt-send-email-mst@kernel.org>
	<CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
	<20180405211945-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

> so an error on the 1st page gets propagated to the caller,
> and that get_user_pages_unlocked eventually calls __get_user_pages
> so it does return an error sometimes.
> 
> Would it be correct to apply the second part of the patch then
> (pasted below for reference) or should get_user_pages_fast
> and all its callers be changed to return 0 on error instead?

0 isn't an error. As SuS sees it (ie from the userspace end of the pile)

returning the number you asked for means it worked

returning a smaller number means it worked partially and that much was
consumed (or in some cases more and the rest if so was lost - depends
what you are reading/writing)

returning 0 means you read nothing as you were at the end of file

returning an error code means it broke, or you should try again
(EAGAIN/EWOULDBLOCK)

The ugly bit there is the try-again semantics needs to exactly match the
attached poll() behaviour or you get busy loops.

Alan
