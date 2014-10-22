Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5B07A6B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 16:13:09 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so1713pac.2
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:13:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qn8si15105055pab.104.2014.10.22.13.13.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 13:13:08 -0700 (PDT)
Date: Wed, 22 Oct 2014 13:13:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
Message-Id: <20141022131308.361a72ba7c6fbf1bd778445a@linux-foundation.org>
In-Reply-To: <5447FC6E.2000207@oracle.com>
References: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
	<544743D6.6040103@samsung.com>
	<20141022114437.72eb61ce3e2348c52ab3d1db@linux-foundation.org>
	<5447FC6E.2000207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 22 Oct 2014 14:50:22 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> On 10/22/2014 02:44 PM, Andrew Morton wrote:
> > On Wed, 22 Oct 2014 09:42:46 +0400 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> > 
> >> > On 10/21/2014 10:15 PM, Sasha Levin wrote:
> >>> > > hstate_sizelog() would shift left an int rather than long, triggering
> >>> > > undefined behaviour and passing an incorrect value when the requested
> >>> > > page size was more than 4GB, thus breaking >4GB pages.
> >> > 
> >>> > > 
> >>> > > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> >>> > > ---
> >>> > >  include/linux/hugetlb.h |    3 ++-
> >>> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> >>> > > 
> >>> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> >>> > > index 65e12a2..57e0dfd 100644
> >>> > > --- a/include/linux/hugetlb.h
> >>> > > +++ b/include/linux/hugetlb.h
> >>> > > @@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
> >>> > >  {
> >>> > >  	if (!page_size_log)
> >>> > >  		return &default_hstate;
> >>> > > -	return size_to_hstate(1 << page_size_log);
> >>> > > +
> >>> > > +	return size_to_hstate(1UL << page_size_log);
> >> > 
> >> > That still could be undefined on 32-bits. Either use 1ULL or reduce SHM_HUGE_MASK on 32bits.
> >> > 
> > But
> > 
> > struct hstate *size_to_hstate(unsigned long size)
> 
> True, but "(1 << page_size_log)" produces an integer rather than long because "1"
> is an int and not long.

My point is that there's no point in using 1ULL because
size_to_hstate() will truncate it anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
