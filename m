Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id DA31B6B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 14:44:38 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so4174736pab.26
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:44:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ta1si14972761pab.62.2014.10.22.11.44.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 11:44:37 -0700 (PDT)
Date: Wed, 22 Oct 2014 11:44:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
Message-Id: <20141022114437.72eb61ce3e2348c52ab3d1db@linux-foundation.org>
In-Reply-To: <544743D6.6040103@samsung.com>
References: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
	<544743D6.6040103@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 22 Oct 2014 09:42:46 +0400 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> On 10/21/2014 10:15 PM, Sasha Levin wrote:
> > hstate_sizelog() would shift left an int rather than long, triggering
> > undefined behaviour and passing an incorrect value when the requested
> > page size was more than 4GB, thus breaking >4GB pages.
> 
> > 
> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> > ---
> >  include/linux/hugetlb.h |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 65e12a2..57e0dfd 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
> >  {
> >  	if (!page_size_log)
> >  		return &default_hstate;
> > -	return size_to_hstate(1 << page_size_log);
> > +
> > +	return size_to_hstate(1UL << page_size_log);
> 
> That still could be undefined on 32-bits. Either use 1ULL or reduce SHM_HUGE_MASK on 32bits.
> 

But

struct hstate *size_to_hstate(unsigned long size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
