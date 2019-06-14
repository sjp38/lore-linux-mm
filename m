Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DABBC31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 149C120850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:14:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="eFeAcZtg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 149C120850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E1446B0003; Fri, 14 Jun 2019 09:14:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86AB76B000A; Fri, 14 Jun 2019 09:14:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 732526B000D; Fri, 14 Jun 2019 09:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22A236B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:14:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s7so3628207edb.19
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lo8jzIeEl3qvMScl2nYeZEzcklK1JpdjNABkHh1fbHg=;
        b=R6pHa5Yx/B0lu1i66Ke4mX0BltcoJqR+9PJM1iUzsjFQ/C/USjyL6WETePAuNKEIPE
         XJidr1vE07A17J46sX3NicEuMFxHhd1YSS51QXSpTmUUZeJvH0ouHZb7egaJFrd8Wcjv
         UVESqyv35zqIF24A0HQhBnfAhFet/EspntL5p2uGN8/PqbtTPKdzeNuXWGaHTUSKdGEB
         1oIFL+BzPjO4a5rC8+kamBqE4M6b5Q9EInsQLAIOx4xV8jtw1VokyM0UYNs7/EIakuP+
         uTkPC68RlzNfxTQfcdnDS9Mb7hxE4UnAQdqLmOioQdQmFM4G92AeMHiWTosFiF1EguIq
         TWQg==
X-Gm-Message-State: APjAAAX9FWgtuwIEBUxn2w6q9gpCu6cJGz1m8wQR9jBheDGoU9cRlLVl
	dc2L06Y1IJcTXbISL6AQB85yJtrvomYUEWysoW8fg4uEnPi8peRXT1Qp/PhNKRLe02RISk2glPX
	1PQsqP6G0GRn0N44dy7io7N1PWotj3k1j3s9cEojTHYW3KWDwoW+vTfX2Br/dQehB4g==
X-Received: by 2002:a50:b13b:: with SMTP id k56mr59751293edd.192.1560518095572;
        Fri, 14 Jun 2019 06:14:55 -0700 (PDT)
X-Received: by 2002:a50:b13b:: with SMTP id k56mr59751220edd.192.1560518094911;
        Fri, 14 Jun 2019 06:14:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560518094; cv=none;
        d=google.com; s=arc-20160816;
        b=hWgmD/h/TFObARKePapyp5QoaSJSNXQOeTFNx5Lf7naT/LxoaB2eYMFSRDc/k+1tL3
         48jRg98RUBYCPAf8AhocYcFn2ivUDeWxGWyJBgpV96ib3BxDE56Huk3++4u01aPZ4LXu
         nKemKX/lUagkkore+R9eXhqyXBYTaiHy2lVS8jLmqRp5ARD0bLRXJn0eXCDYwJCgGac8
         op6KlRXRO1I5brKeUCKfKXqwdCbIKunMnYKpkKmlUg6xgBqIgJBr8twBDKUTPZ8dfgBf
         JjHxQkznbCqgbUidVob/5FVeBRN2y4oB0rcfyzMrVs25eDHn3ISb904gdk4SnVXzYKDn
         tPew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lo8jzIeEl3qvMScl2nYeZEzcklK1JpdjNABkHh1fbHg=;
        b=Y86RUep8NZAAg3XUi+9V59OhW7IV78VutG6gjB9hZ70z4RQtJnlKapjNXs76hlB0YX
         2l+aXKXny0TQDztAQDsN7Ii6bwvBWlyXl9yUF05c1cNGzibsKwcgba0hsJD6XmTEj9fO
         bwcdNqXXcXTtwr5JxhxrQtsE+v+byd5ObIhg/oTZxLetuCDuDNRsFv3fuD0rOoKJ09hW
         C9qSEGNJDqwyTALyUalFWyOpQgsgxuI9N7X/iXiCR52pWU5hGQkFnwTCDyKxBiuZt910
         MWCZc/Z/myyIJxuof8Og1TO1JoGWW1e6Qjb9ueI+AOF+1B6dJbus1mcHFF38SBxOJ79e
         DJ6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=eFeAcZtg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor2853897eda.20.2019.06.14.06.14.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 06:14:54 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=eFeAcZtg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lo8jzIeEl3qvMScl2nYeZEzcklK1JpdjNABkHh1fbHg=;
        b=eFeAcZtgO0/eRC+taEsG3o/626r+gJzLYZLu6JCyggVrs1QqMuSldztZimYV/jdkJJ
         KpqfmnAYmMswNNumhYoKPsqVbi6oXCsorOhOJsdBSnOChpopGRX1/ui0nf+Nlcf6FXPr
         gGpw+PJGJIdyx5tMB8ohHf7Qp8YL0Pn4pTIC3KYego9Ujsgpyiq4SkfHbxvn1Rplq1Pp
         IoST/0AGJDllFkhSDArOhMHcOdLQczefbj/Em08KjBQgqt7nPa6It4nRH8wS9yRppE3g
         SyL/Y8mhbNTD3QF8XNH0x1JlkrNyAot22I9vIuPdXcIIAhttxk+quH+74xWONAEiEFsY
         kixQ==
X-Google-Smtp-Source: APXvYqys9UpU3EDiYN8BSuwDi62d18/VihRzxeEm4B3CXY1/sZgOqGoIC2XqSZyXoR/BuWpsRnWF+g==
X-Received: by 2002:aa7:c619:: with SMTP id h25mr39051647edq.295.1560518094495;
        Fri, 14 Jun 2019 06:14:54 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t3sm593997ejk.56.2019.06.14.06.14.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 06:14:53 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id BB20210086F; Fri, 14 Jun 2019 16:14:53 +0300 (+03)
Date: Fri, 14 Jun 2019 16:14:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190614131453.ludfm4ufzqwa326k@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614093409.GX3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:34:09AM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:
> 
> > +/* Prepare page to be used for encryption. Called from page allocator. */
> > +void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
> > +{
> > +	int i;
> > +
> > +	/*
> > +	 * The hardware/CPU does not enforce coherency between mappings
> > +	 * of the same physical page with different KeyIDs or
> > +	 * encryption keys. We are responsible for cache management.
> > +	 */
> 
> On alloc we should flush the unencrypted (key=0) range, while on free
> (below) we should flush the encrypted (key!=0) range.
> 
> But I seem to have missed where page_address() does the right thing
> here.

As you've seen by now, it will be addressed later in the patchset. I'll
update the changelog to indicate that page_address() handles KeyIDs
correctly.

> > +	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		/* All pages coming out of the allocator should have KeyID 0 */
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
> > +		lookup_page_ext(page)->keyid = keyid;
> > +
> 
> So presumably page_address() is affected by this keyid, and the below
> clear_highpage() then accesses the 'right' location?

Yes. clear_highpage() -> kmap_atomic() -> page_address().

> > +		/* Clear the page after the KeyID is set. */
> > +		if (zero)
> > +			clear_highpage(page);
> > +
> > +		page++;
> > +	}
> > +}
> > +
> > +/*
> > + * Handles freeing of encrypted page.
> > + * Called from page allocator on freeing encrypted page.
> > + */
> > +void free_encrypted_page(struct page *page, int order)
> > +{
> > +	int i;
> > +
> > +	/*
> > +	 * The hardware/CPU does not enforce coherency between mappings
> > +	 * of the same physical page with different KeyIDs or
> > +	 * encryption keys. We are responsible for cache management.
> > +	 */
> 
> I still don't like that comment much; yes the hardware doesn't do it,
> and yes we have to do it, but it doesn't explain the actual scheme
> employed to do so.

Fair enough. I'll do better.

> > +	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
> > +
> > +	for (i = 0; i < (1 << order); i++) {
> > +		/* Check if the page has reasonable KeyID */
> > +		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
> 
> It should also check keyid > 0, so maybe:
> 
> 	(unsigned)(keyid - 1) > keyids-1
> 
> instead?

Makes sense.

-- 
 Kirill A. Shutemov

