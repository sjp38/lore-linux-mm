Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7311CC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:20:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 279552147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:20:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 279552147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B79F18E0003; Tue, 26 Feb 2019 02:20:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B022D8E0002; Tue, 26 Feb 2019 02:20:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F1C18E0003; Tue, 26 Feb 2019 02:20:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7053C8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:20:43 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id o34so11519187qtf.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:20:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tb5JomA0IQ4sPIN8AGg5fQeJMuq0DqoZN9VwyC0krSE=;
        b=pnzCRfnLGCkWCmwAM1Y6WqDYz8zzgC3igyMSFxEfaX39BEQuK6YH7/2rencQHzd/Yn
         Li/630TVkOler2nJ731GJ8SQ5FaTe8/Pwv6Bea0D7yTVJttwqj0Ijml38Nz//Tv2U86h
         yzmsQo+IqalvZVcH3KpwgDsR6ixoZuC7DUMaJpCFVtW40Q2Ze1A/XwqF7HC0NpkHvNJT
         AuCPT74aT2g07fUXb7kko+JWx6kp7hIJsImia+/EtHcPStT8oeSDRC/JgBECJW8iBUnH
         9Sdp+kIEfrAmSZJRTy4Bm1SjxxVewrglq0CeSkicT7l6I39JDkWrhS9HPHlX8Q9EiUGl
         f12Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubgf9klJ+KdZ99JwG/HA/LPeULwkaPCHlIYkCbrc7OSWJf7AFsw
	ZlwDKaJwAt+pxf8m/cEbm55xmVYR3iPMVpNybOMpwgE4RC9d8aZJhJMPbsFYhPW6EI8Cgxd/RaY
	DPPnC/R8KfIH1fYOED7/kCJR9qw8uNE7cUqovwdp7laY0AMLZh9ycap/Q/s5jpoAa+Q==
X-Received: by 2002:a05:620a:1333:: with SMTP id p19mr1191607qkj.165.1551165643167;
        Mon, 25 Feb 2019 23:20:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjhWXYrjrf9AwcK8Wwn8N04nMUT+WgjtBgLmmyw+ffDEkNGoxku2fklw5rAho3J5hU6DQO
X-Received: by 2002:a05:620a:1333:: with SMTP id p19mr1191586qkj.165.1551165642345;
        Mon, 25 Feb 2019 23:20:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551165642; cv=none;
        d=google.com; s=arc-20160816;
        b=bLN5GLFEoJKPnNChsec8lIxkW+PM0YpbzHAGajMUTh9xqXwm0Abjkvzhj6EYAY/lc1
         fSLtvtrODLoMmTVlrng7tAShE3T6lzWsY9eNqRnXYrNa8tO+lOAIYVH7x/YGdOzjEeKm
         e1Sh4gda9a5uYNmhmkeGroRM3O0SMJXlpz0ZAJ7RotNOQeDQzYSRex4oC7eAibs/Q6I0
         lcd+dLE4EYuhvgeadkuChbfZ/zGe0I2dpB4zkRJ5CiHJ6pCOzKjUr+t9Bvler1Fa9BsW
         ZehfogmORJEcjZFU7jaK0Mq7sy4qfv4ZfrTdK7Pm+i749HD9Dh/OrhWD8b4v7S+8k1Q8
         s8iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tb5JomA0IQ4sPIN8AGg5fQeJMuq0DqoZN9VwyC0krSE=;
        b=sZBa6Te35G2tpRU0gVdCdmT8Gni50pFjXwHCp0ThWLWwHeWIAj2Hy3rZZabBbWb2Yt
         uZdshSDnCpdI7cEpwEr3W+CUabYDguNGW/CKRZamxUSF31iSuxUfkEltUkqGgxvAF+pz
         F2ejW1Odw4CH1IXUqZ6BeBzdQiQqTHxocWi31l6ilpI2ixwUd9XinbaEKN2jKrMujjSK
         ZQM1JALCd+Pkxd7LWhEYC29U3tuk1OjXg1uq05hsRpspxolgXpCwuYKfWKUF5/IlWDt7
         C30Wger/2H3w6p1XdkVyZUAifxFv8c4zGI8brdFU1fZar1jz6Wt/b3VsxrqtmxKRETzn
         j8qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p18si2024698qtc.229.2019.02.25.23.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:20:42 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 000A0309705F;
	Tue, 26 Feb 2019 07:20:40 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5F8BB5C6B8;
	Tue, 26 Feb 2019 07:20:30 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:20:28 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190226072027.GK13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
 <20190225205233.GC10454@rapoport-lnx>
 <20190226060627.GG13653@xz-x1>
 <20190226064347.GB5873@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190226064347.GB5873@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 26 Feb 2019 07:20:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 08:43:47AM +0200, Mike Rapoport wrote:
> On Tue, Feb 26, 2019 at 02:06:27PM +0800, Peter Xu wrote:
> > On Mon, Feb 25, 2019 at 10:52:34PM +0200, Mike Rapoport wrote:
> > > On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> > > > From: Shaohua Li <shli@fb.com>
> > > > 
> > > > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > > > this doesn't split/merge vmas.
> > > > 
> > > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > > Cc: Rik van Riel <riel@redhat.com>
> > > > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > > > Cc: Mel Gorman <mgorman@suse.de>
> > > > Cc: Hugh Dickins <hughd@google.com>
> > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > Signed-off-by: Shaohua Li <shli@fb.com>
> > > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > > [peterx:
> > > >  - use the helper to find VMA;
> > > >  - return -ENOENT if not found to match mcopy case;
> > > >  - use the new MM_CP_UFFD_WP* flags for change_protection
> > > >  - check against mmap_changing for failures]
> > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > > ---
> > > >  include/linux/userfaultfd_k.h |  3 ++
> > > >  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
> > > >  2 files changed, 57 insertions(+)
> > > > 
> > > > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > > > index 765ce884cec0..8f6e6ed544fb 100644
> > > > --- a/include/linux/userfaultfd_k.h
> > > > +++ b/include/linux/userfaultfd_k.h
> > > > @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> > > >  			      unsigned long dst_start,
> > > >  			      unsigned long len,
> > > >  			      bool *mmap_changing);
> > > > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > > > +			       unsigned long start, unsigned long len,
> > > > +			       bool enable_wp, bool *mmap_changing);
> > > > 
> > > >  /* mm helpers */
> > > >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > > index fefa81c301b7..529d180bb4d7 100644
> > > > --- a/mm/userfaultfd.c
> > > > +++ b/mm/userfaultfd.c
> > > > @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> > > >  {
> > > >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
> > > >  }
> > > > +
> > > > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > > > +{
> > > > +	struct vm_area_struct *dst_vma;
> > > > +	pgprot_t newprot;
> > > > +	int err;
> > > > +
> > > > +	/*
> > > > +	 * Sanitize the command parameters:
> > > > +	 */
> > > > +	BUG_ON(start & ~PAGE_MASK);
> > > > +	BUG_ON(len & ~PAGE_MASK);
> > > > +
> > > > +	/* Does the address range wrap, or is the span zero-sized? */
> > > > +	BUG_ON(start + len <= start);
> > > 
> > > I'd replace these BUG_ON()s with
> > > 
> > > 	if (WARN_ON())
> > > 		 return -EINVAL;
> > 
> > I believe BUG_ON() is used because these parameters should have been
> > checked in userfaultfd_writeprotect() already by the common
> > validate_range() even before calling mwriteprotect_range().  So I'm
> > fine with the WARN_ON() approach but I'd slightly prefer to simply
> > keep the patch as is to keep Jerome's r-b if you won't disagree. :)
> 
> Right, userfaultfd_writeprotect() should check these parameters and if it
> didn't it was a bug indeed. But still, it's not severe enough to crash the
> kernel.
> 
> I hope Jerome wouldn't mind to keep his r-b with s/BUG_ON/WARN_ON ;-)
> 
> With this change you can also add 
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Thanks!  Though before I change anything... please note that the
BUG_ON()s are really what we've done in existing MISSING code.  One
example is userfaultfd_copy() which did validate_range() first, then
in __mcopy_atomic() we've used BUG_ON()s.  They make sense to me
becauase userspace should never be able to trigger it.  And if we
really want to change the BUG_ON()s in this patch, IMHO we probably
want to change the other BUG_ON()s as well, then that can be a
standalone patch or patchset to address another issue...

(and if we really want to use WARN_ON, I would prefer WARN_ON_ONCE, or
 directly return the errors to avoid DOS).

I'll see how you'd prefer to see how I should move on with this patch.

Thanks,

-- 
Peter Xu

