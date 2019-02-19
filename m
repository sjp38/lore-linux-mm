Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F19EFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB8C621738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:53:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB8C621738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 550A88E0003; Tue, 19 Feb 2019 10:53:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FEDC8E0002; Tue, 19 Feb 2019 10:53:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EF128E0003; Tue, 19 Feb 2019 10:53:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D676C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:53:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id u12so525344edo.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:53:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DLY6qCQGXLnojyXzXLr99CiHL/CJASETf8/VYzNhFVc=;
        b=EW7kyq/LHmeWlSFBZPQpDt+E4dOxVhzxqT8hK4P66Ef+dtwQfeMg++28xozTdNUY3o
         lxBni4gx8s8xPIz+sNaPBEG4hejTSpd86RT4quwAEAoo7LGDvV2wTl6rZsQOxonbqm8k
         q+oG46uNp7WLRdbPC1kPrF+JkxaLdqWRKj/dSDY7Ad/YdZxh85UyCy8SIGhkooz9eUph
         1ciAcSYwZm2Bz86y+KH8HnZB+YIu74hLjwSU8/i/K3weIGTF+fL+ieOIS+Jn7sOPhQQN
         mzwJX+JRvM0SuRj59FBQQhwaaky4kJkrJXbXCfxP0wtUCz5YYLPblda7fApBP3jtWTzg
         ui/A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuZ2fqyKICJWnti2qTXAmFSxGSzrjacl0f6DW4bp4dw3qGfCP+NT
	BHb67Rj6Wn/wQbdMlM4vwsW3v+kuu7EAoyqTON1q37dgx+/1LkeY1pBI9a8dBWiLyFqATAh4iEE
	dg8pBqjXU/G42ASHccxD+UdEAtkyXhs2bOhxUXbWOyecm3VXNC0qZXdNAeIq8ZRY=
X-Received: by 2002:a17:906:29cd:: with SMTP id y13mr20550315eje.35.1550591607380;
        Tue, 19 Feb 2019 07:53:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpXSwctTS5XroGviiHSM4ZujBaZ24vE/b3OCsX0AhmCUQxbl+9HPH9HmR3WHtYk24jLmp0
X-Received: by 2002:a17:906:29cd:: with SMTP id y13mr20550248eje.35.1550591606019;
        Tue, 19 Feb 2019 07:53:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550591606; cv=none;
        d=google.com; s=arc-20160816;
        b=NZIVJw7iXGRrF9ZW26wfWFBSm+ypIUvE2D9FERhoYtSa1x6e62n3JaKi7n0WFcD1Dy
         BZpO9ieDKynfvhT/EWzwt0ITy8UY6NWGlT7cgSH+kd8D3Vu1oVZIvKCAWcFLOFnB7xLX
         PzdLOHOOyt7SCIDE6nBpTMXd6U4sHMG0pRSg2uMfq2rIIPDbo2l5DQKuAxYc1hvvb8bF
         M6T+p4QlZRJ41ydjA/5HHP/YsXgT+zu7hGGB3vXkyZ5hMgE8odUz4H2+jY4Png29bpcD
         Se2Je4lfilUyNSDl48Z2t73vfQsoH0s/OgQlSRQfQ3be9IB+kNZzkKhS/kuEaALwKfWh
         sfwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DLY6qCQGXLnojyXzXLr99CiHL/CJASETf8/VYzNhFVc=;
        b=RG2fnXK3CriccYN5w2LS6KeKh/aCN6U/bVL5M+44ELGt/H3+rm9ZGs6bU5DxUOYaH8
         YiloIfUQ4BQ7pKQ4Zty/x/wvH7eyzjovKssqlmthMFcQf/LdUPlFlHNBs/L56ln7pVGP
         RhznwNhmeWogUjLSoTQBTdR7IYqSoPZ+khVP0l7Zbki25lnDj0gwszKYv7SD7eoDVngx
         Pk8ErQ9psQ5UlCni/gJn4UyTMsKRTovTqTIyLlEOb5jLdSHwna/Zo8WyR4W8N5hsjcus
         FUXNTjxV2gREGQu+pp2YtdOaQTqQ3Z6Nj0o0AfxnIYA1jzvZkBuLQdrhUC2F4Ep2CVGe
         uOgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id i6si2702455edk.125.2019.02.19.07.53.25
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 07:53:26 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id D6F964317; Tue, 19 Feb 2019 16:53:24 +0100 (CET)
Date: Tue, 19 Feb 2019 16:53:24 +0100
From: Oscar Salvador <osalvador@suse.de>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	hughd@google.com, viro@zeniv.linux.org.uk,
	torvalds@linux-foundation.org
Subject: Re: mremap vs sysctl_max_map_count
Message-ID: <20190219155320.tkfkwvqk53tfdojt@d104.suse.de>
References: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
 <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
 <20190218111535.dxkm7w7c2edgl2lh@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218111535.dxkm7w7c2edgl2lh@kshutemo-mobl1>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 02:15:35PM +0300, Kirill A. Shutemov wrote:
> On Mon, Feb 18, 2019 at 10:57:18AM +0100, Vlastimil Babka wrote:
> > IMHO it makes sense to do all such resource limit checks upfront. It
> > should all be protected by mmap_sem and thus stable, right? Even if it
> > was racy, I'd think it's better to breach the limit a bit due to a race
> > than bail out in the middle of operation. Being also resilient against
> > "real" ENOMEM's due to e.g. failure to alocate a vma would be much
> > harder perhaps (but maybe it's already mostly covered by the
> > too-small-to-fail in page allocator), but I'd try with the artificial
> > limits at least.
> 
> There's slight chance of false-postive -ENOMEM with upfront approach:
> unmapping can reduce number of VMAs so in some cases upfront check would
> fail something that could succeed otherwise.
> 
> We could check also what number of VMA unmap would free (if any). But it
> complicates the picture and I don't think worth it in the end.

I came up with an approach which tries to check how many vma's are we going
to split and the number of vma's that we are going to free.
I did several tests and it worked for me, but I am not sure if I overlooked
something due to false assumptions.
I am also not sure either if the extra code is worth, but from my POV
it could avoid such cases where we unmap regions but move_vma()
is not going to succeed at all.


It is not yet complete (sanity checks are missing), but I wanted to show it
to see whether it is something that is worth spending time with:

diff --git a/mm/mremap.c b/mm/mremap.c
index 3320616ed93f..f504c29d2af4 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -494,6 +494,51 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	return vma;
 }
 
+static int pre_compute_maps(unsigned long addr, unsigned long len)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma, *vma_end;
+	unsigned long end;
+	int maps_needed = 0;
+
+	end = addr + len;
+
+	vma = find_vma(mm, addr);
+	if (!vma)
+		return 0;
+	vma_end = find_vma(mm, end);
+
+	if (addr >= vma->vm_start && end <= vma->vm_end) {
+		/*
+		 * Possible outcomes when dealing with a single vma:
+		 * the vma will be entirely removed: map_count will be decremented by 1
+		 * it needs to be split in 2 before unmapping: map_count not changed
+		 * it needs to be split in 3 before unmapping: map_count incremented by 1
+		 */
+		if (addr > vma->vm_start && end < vma->vm_end)
+			maps_needed++;
+		else if (addr == vma->vm_start && end == vma->vm_end)
+			maps_needed--;
+	} else {
+		struct vm_area_struct *tmp = vma;
+		int vmas;
+
+		if (addr > tmp->vm_start)
+			vmas = -1;
+		else
+			vmas = 0;
+
+		while (tmp != vma_end) {
+			if (end >= tmp->vm_end)
+				vmas++;
+			tmp = tmp->vm_next;
+		}
+		maps_needed -= vmas;
+	}
+
+	return maps_needed;
+}
+
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		unsigned long new_addr, unsigned long new_len, bool *locked,
 		struct vm_userfaultfd_ctx *uf,
@@ -516,6 +561,24 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
+	/*
+	 * Worst-scenario case is when a vma gets split in 3 before unmaping it.
+	 * So, that would mean 2 (1 for new_addr and 1 for addr) more maps to
+	 * the ones we already hold.
+	 * If that is the case, let us check further if we are going to free
+	 * enough to go beyond the check in move_vma().
+	 */
+	if ((mm->map_count + 2) >= sysctl_max_map_count - 3) {
+		int maps_needed = 0;
+
+		maps_needed += pre_compute_maps(new_addr, new_len);
+		if (old_len > new_len)
+			maps_needed += pre_compute_maps(addr + new_len, old_len - new_len);
+
+		if ((mm->map_count + maps_needed) >= sysctl_max_map_count - 3)
+			return -ENOMEM;
+	}
+
 	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
 	if (ret)
 		goto out;
Thanks
-- 
Oscar Salvador
SUSE L3

