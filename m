Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D82C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE9782085A
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 06:06:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE9782085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A0546B0007; Fri, 19 Jul 2019 02:06:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 351438E0003; Fri, 19 Jul 2019 02:06:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 218988E0001; Fri, 19 Jul 2019 02:06:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C974E6B0007
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:06:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so21355784edu.11
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 23:06:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=99U5Qb6MiFjuWuEj/PnyOPEz88ltPSXDcTybjUinW7w=;
        b=U4vEsq2/ICOAQGmAoUylyPeZ1zz5TNgGYwDlcWOgyZ4VK86A9lBtSHdfbGQUzFteUB
         EpwvMojfTn4aiXA2GEOC7Cq4QEX8k6k1JR6vN5P+y6rSWrVIO5fvId06nkEW8OGRMbg1
         6zsXf3GZYi6H01XQPIKRBDH5nkIImpoCVf/zadXVjz2ryfp+/d2ojuH8YChoME1fTP5r
         cjIwvlj1KvoT1w+lGnFpLpyLwgufhgiUzZxhbs/r+Syg9KU97rIoIJuLu6NwZq/g/1pY
         8OhWLM2y0QYOyqMnuTkRP+H0sqPLTrCcAOXXcg7rU3sJLfi/hTbu7rr2sZML4+1TaXVu
         l0Wg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWRjoBZKwc3C6cVjH8+oGQ63Xa3qdrqYjnRjknYLQvJVPRVBuzx
	KM62jM/66zOSm2i+kN8nVkjKEruIY7iTWwLhLsiyc13ivGkGIzsOCQCRsaHLcZYuKgAFFUNA8Ll
	c1bZySpMTSEfvNJZOYHGsE90Nmxfzzzu0FJ0Yuw3Hde/rG05L74KP5XcdbnFG4lA=
X-Received: by 2002:a17:906:7013:: with SMTP id n19mr39204549ejj.65.1563516376385;
        Thu, 18 Jul 2019 23:06:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbb+FcwIOBWKY2Xbn+L+UzGo6owaFCapvAo7fGWyUe+mwgY+xLYogvlWGKv9D+SydmbvHz
X-Received: by 2002:a17:906:7013:: with SMTP id n19mr39204523ejj.65.1563516375727;
        Thu, 18 Jul 2019 23:06:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563516375; cv=none;
        d=google.com; s=arc-20160816;
        b=dOLB5DOQ8I4SwFWnHJP5hNJjGCByAAuZDum4719VmBbafVMlb24x1vjAHnaB11pg8Y
         O28eh6PLs6bkxkNC8ajmJHk7sQPD3i1n2Qzvrf55n316iGhu36b+KEJhhaNZf7WKBSmY
         NW+2BFI3swDadhtwS8wMCXUGu4clgcXsp5Xk1h5IS3CTLe3PFwqbmo715f3MLHpMtDza
         qhUni9lzfOPR/hOcGyjkak24bgHrmq/KuODeMQYlEI9fOdw20m2BuYpDSG1EJAHodJZ1
         aG42aOIfpMzPXBxAgw1C27FKHFfNtCI4JTWF0hlAIzkyJGq18Y/GIFpXHgV0MpxVvCGi
         Y95g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=99U5Qb6MiFjuWuEj/PnyOPEz88ltPSXDcTybjUinW7w=;
        b=JeWLb0DmLB1o15jj91wVShccyA0mgqFFfe3PrFwL0waMAbxbsxhXKSZyT9BxRXtIkW
         I6pgQqvV+U/GtDXKc8N4NqV4qDsu6ruPllie0F4BFoWqUFV/HEyMmguITOrCW5ENrMv/
         9nqJYww5b1+I/qInrX4qjjU5WMTrWYZPUaiz8sbZFvR+LCKn2jDXGe/q/Zf/U2KwvSNa
         zBblrvBWD80UIB61vSR5Aqe6WMiUO42MqwbQwc09tQh5fb7BnSjUyRCqfSF56m7JiCgY
         G+AWgyDaoJndsnd40d0CgTE2t4AxWIqlo6nSLVMYc0fM+vGNjB+e7+PNZ9z9+3PRysf2
         goCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u8si111483edm.69.2019.07.18.23.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 23:06:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A40D3B0A5;
	Fri, 19 Jul 2019 06:06:14 +0000 (UTC)
Date: Fri, 19 Jul 2019 08:06:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Nicholas Piggin <npiggin@gmail.com>,
	Vasily Gorbik <gor@linux.ibm.com>, Rob Herring <robh@kernel.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Banman <andrew.banman@hpe.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>,
	Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v3 06/11] mm/memory_hotplug: Allow arch_remove_pages()
 without CONFIG_MEMORY_HOTREMOVE
Message-ID: <20190719060610.GH30461@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
 <20190701080141.GF6376@dhcp22.suse.cz>
 <20190701125112.GW6376@dhcp22.suse.cz>
 <717d8b84-2233-97f9-56cb-0b9e22732d30@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <717d8b84-2233-97f9-56cb-0b9e22732d30@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-07-19 12:54:20, David Hildenbrand wrote:
[...]
> So I'm leaving it like it is. arch_remove_memory() will be mandatory for
> architectures implementing arch_add_memory().

I do agree that removing CONFIG_MEMORY_HOTREMOVE makes some sense. But
this patch being a mid step should be simpler rather than going half way
to get there. I would have liked the above for the purpose of this patch
more and then go with another one to remove the config altogether. But
Andrew has already sent his patch bomb including this series to Linus so
this is all moot.
-- 
Michal Hocko
SUSE Labs

