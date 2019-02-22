Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8204C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FF692086C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:51:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FF692086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B49F8E00E8; Thu, 21 Feb 2019 22:51:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23BC18E00E7; Thu, 21 Feb 2019 22:51:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DDB98E00E8; Thu, 21 Feb 2019 22:51:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D36C78E00E7
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 22:51:33 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 35so1019401qtq.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:51:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cjBmkBNvP0oyWR68b7yDxcMp6K9I5cUYTljAYTlKDVs=;
        b=Po6K+bg+vPJk0q5u0OC2b8onlEp6n5C5RH/+EczJKcOzUCdvp3og1XdfvqJ0A14/ou
         I3zDfCyk7S21yhPi2rKBzqOs7sTvkeHn0tBDScJuv/3rCsqdvrkdQcj+J95Dn7ZNyOPu
         tzrItVonOxRfW78OlooD/qfGNLGDYtMK2Cori1jol62zI1AUAkrJaS7YfE2N6KDQGQXW
         2dTme8y2POPncLICqgeNcFSkElyuMGyRJHzrAGUx17dO5xLv/MEcW/fb0Lsu81k9a1qA
         1UFLyog2DkM83tAFn2PafDCWoNyBERSp1TlmKNe8c3Nnlr1ibFT5hfK135kaiJml1Rio
         HWfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaeAOI5z6mCXKe5eGKpfCOM9aEB+3ylO5DbeqHhKl56FTFWViwd
	J8tR/Wx0oQWLAil/uwbbIF5ri/Er7ILHgAq+8CH5sl7DAoHMKichP18orO4d9YtIGqtw3zvG2x1
	HeIlTBF4eU+wh3EqGUmXnT2FQ6eOBd4NqSlbxHeEz7Exnl85wvnPlFHtbrNxGWnNogQ==
X-Received: by 2002:a37:f506:: with SMTP id l6mr1564342qkk.110.1550807493611;
        Thu, 21 Feb 2019 19:51:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkBH5idsKIz922ieAEp1qw2mG25pBZHzM09EIE8GMpoQv1hamdx1CdsOfFsRfPVQqK8jf7
X-Received: by 2002:a37:f506:: with SMTP id l6mr1564324qkk.110.1550807492871;
        Thu, 21 Feb 2019 19:51:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550807492; cv=none;
        d=google.com; s=arc-20160816;
        b=Wlqyis61/Y7w0zO3XVNQBqAYUgiTHsqLPTV8qjhTaQWamB9LcLl5dzRxscsYz3K5QI
         ySy6ZoMEbggx6+iflPWpxhDV3tYnQPSXgN47TEf3Q9ZWZp0LabKX9KHuWwy703P9RFfb
         MpXuOXrEFQXOT8nuzja392E7n76p81WPeV/UnJo1UV4vuwshiTWrW2iiJ7VKdB+ifWrx
         Xzk3w3G9ugUo+zSqaDz/b6rE3xh2wg/rwqX9q5fr9CXdMOSVeY8lQ2RHlwndxnL5zD2n
         JNHsoLco6MiS6FghR+vgz8rndm+j+BsGFcRCsSmtpbdc/lvQF7KyywTA9W5hUN3aF8FC
         SjEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=cjBmkBNvP0oyWR68b7yDxcMp6K9I5cUYTljAYTlKDVs=;
        b=TqfOcbUZRNpnDscOlswyI0KFVBbMNCGzY/Z26jEOiOGr9djbPBORNDWkFgWFq3sGyT
         F12Ub3Mds3AtKmt2kQN3P9F3oUU8UrtemcgE28J/71zGc7VA+4VrluoGLTpX7VNiS+/0
         R9h57F21fKSCCZm4VVXsqBRcTvnywTMsn+b7lE5U/5I4irAeDaqX7YX3E5Y+pQWC2Nnq
         mUeLUI+a1gA+hkTA+Q+LL+g+CbBiYr+35RxVeGGrboWE4lgjkBG4CKcTG7BMd07Z0N+W
         SMJtd028whygh/O1xRkwtLEMvvSyN7frDGfC3vIQ1Qn9fWaIIG8F/jBhq8vR02HsV8XZ
         sVcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w53si210957qtk.33.2019.02.21.19.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 19:51:32 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9B9433082B69;
	Fri, 22 Feb 2019 03:51:31 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 131B960BE6;
	Fri, 22 Feb 2019 03:51:21 +0000 (UTC)
Date: Fri, 22 Feb 2019 11:51:17 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 02/26] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190222035117.GC8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-3-peterx@redhat.com>
 <20190221152956.GB2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221152956.GB2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 22 Feb 2019 03:51:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 10:29:56AM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:08AM +0800, Peter Xu wrote:
> > The idea comes from the upstream discussion between Linus and Andrea:
> > 
> >   https://lkml.org/lkml/2017/10/30/560
> > 
> > A summary to the issue: there was a special path in handle_userfault()
> > in the past that we'll return a VM_FAULT_NOPAGE when we detected
> > non-fatal signals when waiting for userfault handling.  We did that by
> > reacquiring the mmap_sem before returning.  However that brings a risk
> > in that the vmas might have changed when we retake the mmap_sem and
> > even we could be holding an invalid vma structure.
> > 
> > This patch removes the special path and we'll return a VM_FAULT_RETRY
> > with the common path even if we have got such signals.  Then for all
> > the architectures that is passing in VM_FAULT_ALLOW_RETRY into
> > handle_mm_fault(), we check not only for SIGKILL but for all the rest
> > of userspace pending signals right after we returned from
> > handle_mm_fault().  This can allow the userspace to handle nonfatal
> > signals faster than before.
> > 
> > This patch is a preparation work for the next patch to finally remove
> > the special code path mentioned above in handle_userfault().
> > 
> > Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> > Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> See maybe minor improvement
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> [...]
> 
> > diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> > index 58f69fa07df9..c41c021bbe40 100644
> > --- a/arch/arm/mm/fault.c
> > +++ b/arch/arm/mm/fault.c
> > @@ -314,12 +314,12 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
> >  
> >  	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
> >  
> > -	/* If we need to retry but a fatal signal is pending, handle the
> > +	/* If we need to retry but a signal is pending, handle the
> >  	 * signal first. We do not need to release the mmap_sem because
> >  	 * it would already be released in __lock_page_or_retry in
> >  	 * mm/filemap.c. */
> > -	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
> > -		if (!user_mode(regs))
> > +	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {
> 
> I rather see (fault & VM_FAULT_RETRY) ie with the parenthesis as it
> avoids the need to remember operator precedence rules :)

Yes it's good practise.  I've been hit by the lock_page() days ago
already so I think I'll remember (though this patch was earlier :)

I'll fix all the places in the patch.  Actually I noticed that there
are four of them.  And I've taken the r-b after the changes.  Thanks,

> 
> [...]
> 
> > diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
> > index 68d5f2a27f38..9f6e477b9e30 100644
> > --- a/arch/nds32/mm/fault.c
> > +++ b/arch/nds32/mm/fault.c
> > @@ -206,12 +206,12 @@ void do_page_fault(unsigned long entry, unsigned long addr,
> >  	fault = handle_mm_fault(vma, addr, flags);
> >  
> >  	/*
> > -	 * If we need to retry but a fatal signal is pending, handle the
> > +	 * If we need to retry but a signal is pending, handle the
> >  	 * signal first. We do not need to release the mmap_sem because it
> >  	 * would already be released in __lock_page_or_retry in mm/filemap.c.
> >  	 */
> > -	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
> > -		if (!user_mode(regs))
> > +	if (fault & VM_FAULT_RETRY && signal_pending(current)) {
> 
> Same as above parenthesis maybe.
> 
> [...]
> 
> > diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
> > index 0e8b6158f224..09baf37b65b9 100644
> > --- a/arch/um/kernel/trap.c
> > +++ b/arch/um/kernel/trap.c
> > @@ -76,8 +76,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
> >  
> >  		fault = handle_mm_fault(vma, address, flags);
> >  
> > -		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
> > +		if (fault & VM_FAULT_RETRY && signal_pending(current)) {
> 
> Same as above parenthesis maybe.
> 
> [...]

Regards,

-- 
Peter Xu

