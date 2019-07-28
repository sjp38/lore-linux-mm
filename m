Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D572C7618B
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 17:56:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD1942085A
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 17:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GzsJvhau"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD1942085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A32C8E0003; Sun, 28 Jul 2019 13:56:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 254408E0002; Sun, 28 Jul 2019 13:56:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 142EC8E0003; Sun, 28 Jul 2019 13:56:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0FA48E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 13:56:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so36824289pfj.4
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 10:56:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=N9NgY+9REzKo/zxFxg1LeJgCnxBhmvyoEoZBcU1LXk0=;
        b=uQTMRz/4EraBQF8V3pg42lBBUKC0KBVBVxNiZy4Uj7t8+ngWnYAWgYLq4RNh6xhJ5F
         X76dZgGRP/CZGCCOTxhe8GV1vm/mXhWiaTWDp5sc6wS/sV9KJccgkrb78BCEoM/SsEEz
         EPpi1A+3J6318TELg1fyIFFCXj6XhXwq4E/8lw9cBePLgcSmlydzwFJTFPP6vAoCn8RW
         oNDty3dXII6QVGMnNt+p7Iy85btvqbD5PZVQqN/foQRMBfMJa4hoRFPzqWaMLbwF5uiN
         gJNeFfWLbgERSRjOa5DnMg8Xi/Gn2OZAqVX/1HyfqrfW/fWJT9ufMXo1nmRcU5MeDwO9
         QDwA==
X-Gm-Message-State: APjAAAV57Zeh0sZ9J9CCql4aMYxXRDNfA4fvltc+kSgLQqYmNGabqBah
	99QN4uYnldy4YWbMB/feCBAWX7+t1OnmbZQd73zRwDl1wOQ1/mEi+0SoQ7a739mtxklpfTZBdWN
	TtxlYLkfV917m85ONItUN6/eDGw/kI3bQoMnG+i/DEqW8z3DlUq253uFXmsRXwcAHXg==
X-Received: by 2002:a63:e5a:: with SMTP id 26mr97113490pgo.3.1564336587295;
        Sun, 28 Jul 2019 10:56:27 -0700 (PDT)
X-Received: by 2002:a63:e5a:: with SMTP id 26mr97113459pgo.3.1564336586437;
        Sun, 28 Jul 2019 10:56:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564336586; cv=none;
        d=google.com; s=arc-20160816;
        b=kguSlolFnptN8rpFgLo7sKy9p0AYsze+QhYVRMpeKEUqMGJPbNTAiKrBSH+rRqF2KH
         PRHr2wN+/V1RxoAyEkMBPhae9+Nqoz6REIE7mRAvuKCz9bQXNa7jS0cnrTkqPDGqNQym
         YGREDivqJjbXpWV4NGPcnzPjz6tRWKUy+rr3zXXuXERad+XYUwEArq0h3RejSmXINjZd
         esWFpvwW9TMMwfDBiDAu/U+gmga3TY+/1hVp/gPDiU5YfIzWnmudFCzNV4aeeS1QeJh5
         uAO2+gEY8v5hKKcyB4X/LqLOic4R4BpihfPkSmiVFYmS76Vp4c5K63SdYiIeFZ2qWZ2V
         i+Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=N9NgY+9REzKo/zxFxg1LeJgCnxBhmvyoEoZBcU1LXk0=;
        b=EJxb7O0M7DDSiEGiQN8o7Z4T1e+PTkbqL2EzRq4mPt/UYZsfU27qkxGI7rVHk+9837
         4vwFpZPwbNwYWFDjnehXyG7kqdicRNJyMq13Tmc5NfQ7+5dkVoYIxw6RhKkO6ff4q5dH
         ubntp4ZoXVT88g90Nue5nVy1fFdo4k/9UMixVawzIicAG3+UBCuY/UkJuV6t0NY8Y3Cu
         wmUaHuHllWmRSA0movaZcSsZx8kK8KE3u0gtrEgmRMqApFVpDj7xtm9URABVd+HEONpK
         j/f1Qx5VSZkngNPA74FcAr6VvpBd6KbEdDKAgvQkuEYo9YEdYby7r/0+kAsQjdys4bLH
         6Rvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GzsJvhau;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d5sor71475890plr.38.2019.07.28.10.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Jul 2019 10:56:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GzsJvhau;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=N9NgY+9REzKo/zxFxg1LeJgCnxBhmvyoEoZBcU1LXk0=;
        b=GzsJvhauRWL7PSWXgxuUnBswR65wSjC/py5XB3CPMQMeojWt77IBYkNRVM1FAbXk27
         506oHvYhfbKfQHASajWdGfzcxWXuaM+EE90pZMCVzg1/jcmA01ANWDM9qx4yyf3nK6OG
         ErWIGw8w0Bxt+ERqVQheE3V2hjxHXiMp/k6tLOJESHKOXt0teCUfCB/6JBjiq+7jslyF
         fUgULUk17ruS7rZ9ci/4hG/BS1W255rKAZxc5aV1yCTdtRvdi4NBbZPd7L0sIfyMemu8
         YoHsPEFahFzKV19L36h5STSddrh+ZeEII+JrTGdQZ2kW7GxFt4M8+Oltw/oSv6cKYft6
         RFVQ==
X-Google-Smtp-Source: APXvYqxdDpWI8zTtqYX0tdce8r2lBw5SdnOIWMVyhFqx7s8oneYHV9QX5UBnVitKKGx272Jx+KohgA==
X-Received: by 2002:a17:902:76c7:: with SMTP id j7mr103163221plt.247.1564336585990;
        Sun, 28 Jul 2019 10:56:25 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id h12sm67756728pje.12.2019.07.28.10.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 10:56:25 -0700 (PDT)
Date: Sun, 28 Jul 2019 23:26:17 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Hillf Danton <hdanton@sina.com>
Cc: sivanich@sgi.com, arnd@arndb.de, ira.weiny@intel.com,
	jhubbard@nvidia.com, jglisse@redhat.com, gregkh@linuxfoundation.org,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/1] sgi-gru: Remove *pte_lookup functions
Message-ID: <20190728175617.GA5391@bharath12345-Inspiron-5559>
References: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com>
 <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 27, 2019 at 05:22:28PM +0800, Hillf Danton wrote:
> 
> On Fri, 26 Jul 2019 12:42:26 -0700 (PDT) Bharath Vedartham wrote:
> > 
> >  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
> >  		    int write, int atomic, unsigned long *gpa, int *pageshift)
> >  {
> >  	struct mm_struct *mm = gts->ts_mm;
> >  	struct vm_area_struct *vma;
> >  	unsigned long paddr;
> > -	int ret, ps;
> > +	int ret;
> > +	struct page *page;
> >  
> >  	vma = find_vma(mm, vaddr);
> >  	if (!vma)
> > @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
> >  
> >  	/*
> >  	 * Atomic lookup is faster & usually works even if called in non-atomic
> > -	 * context.
> > +	 * context. get_user_pages_fast does atomic lookup before falling back to
> > +	 * slow gup.
> >  	 */
> >  	rmb();	/* Must/check ms_range_active before loading PTEs */
> > -	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> > -	if (ret) {
> > -		if (atomic)
> > +	if (atomic) {
> > +		ret = __get_user_pages_fast(vaddr, 1, write, &page);
> > +		if (!ret)
> >  			goto upm;
> > -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> > +	} else {
> > +		ret = get_user_pages_fast(vaddr, 1, write, &page);
> > +		if (!ret)
> >  			goto inval;
> >  	}
> > +
> > +	paddr = page_to_phys(page);
> 
> You may drop find_vma() above if PageHuge(page) makes sense here.
I don't think it does. Hugepage support is still incomplete for this
driver.

Thank you
Bharath
> > +	put_user_page(page);
> > +
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		*pageshift = HPAGE_SHIFT;
> > +	else
> > +		*pageshift = PAGE_SHIFT;
> > +
> >  	if (is_gru_paddr(paddr))
> >  		goto inval;
> > -	paddr = paddr & ~((1UL << ps) - 1);
> > -	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> > -	*pageshift = ps;
> > +	paddr = paddr & ~((1UL << *pageshift) - 1);
> > +	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> > +
> >  	return VTOP_SUCCESS;
> >  
> >  inval:
> > -- 
> > 2.7.4
> 

