Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E67D26B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 21:06:58 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so45818534pdn.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:06:58 -0700 (PDT)
Received: from x35.xmailserver.org (x35.xmailserver.org. [64.71.152.41])
        by mx.google.com with ESMTPS id gz3si5976634pac.28.2015.03.25.18.06.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 18:06:57 -0700 (PDT)
Received: from davide-lnx3.corp.ebay.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S423654> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 25 Mar 2015 21:07:04 -0400
Date: Wed, 25 Mar 2015 18:06:51 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.LSU.2.11.1503251708530.5592@eggly.anvils>
Message-ID: <alpine.DEB.2.10.1503251754320.26501@davide-lnx3>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 25 Mar 2015, Hugh Dickins wrote:

> When you say "tracking back to 3.2.x", I think you mean you've tried as
> far back as 3.2.x and found the same behaviour, but not tried further?
> 
> From the source, it looks like this is unchanged since MAP_HUGETLB was
> introduced in 2.6.32.  And is the same behaviour as you've been given
> with hugetlbfs since it arrived in 2.5.46.

Went back checking the application logs, an I had to patch the code (the 
application one - to align size on munmap()) on May 2014.
But it might be we started noticing it at that time, because before the 
allocation pattern was simply monotonic, so it could be it was always 
there.
The bug test app is ten lines of code, to verify that.


> The patch looks to me as if it will do what you want, and I agree
> that it's displeasing that you can mmap a size, and then fail to
> munmap that same size.
> 
> But I tend to think that's simply typical of the clunkiness we offer
> you with hugetlbfs and MAP_HUGETLB: that it would have been better to
> make a different choice all those years ago, but wrong to change the
> user interface now.
> 
> Perhaps others will disagree.  And if I'm wrong, and the behaviour
> got somehow changed in 3.2, then that's a different story and we
> should fix it back.

This is not an interface change, in the sense old clients will continue to 
work.
This is simply respecting the mmap(2) POSIX specification, for a feature 
which has been exposed via mmap(2).



- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
