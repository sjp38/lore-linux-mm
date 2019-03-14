Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A567EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:49:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F8A20811
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:49:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F8A20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B338E0003; Thu, 14 Mar 2019 11:49:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0288A8E0001; Thu, 14 Mar 2019 11:49:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E83B78E0003; Thu, 14 Mar 2019 11:49:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A96E48E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:49:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x98so236222ede.18
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:49:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UmwXuI0Tu6eH1ES7L3coBYvPrhIxuARhUcCL5HJ3a0s=;
        b=Nv9iQg4k7VYwMYceyiJH5Caf3mOBOI2SIcITob/mRZ2Pz5YqFK1SiwgzgntmWxZw+8
         uvCmqzvzp9IUuT0zobsV7b25jgcdcJlI9lADpZJ0dx8QjqxUGtz3YATdyeTCISSSMMWp
         IkURQBZlnD+nXYYFxQPtRSL0BxJq6KA8TKKCfVyDnpZHQZ21T2TiuBqqGFkLzYs7mRVd
         FB+Js0/74grpeUs32aObW70SzLxkl/EDdDpy+rJYpOPISKW0fE+p9QhRmbcF321WTwXS
         j0fNoIQ8OCghQ/hvUp/AllQvuFIrZ5CT4HumI1Z5lBkdqec5zCQNclqWufB5Rs9Rjjyy
         8l5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVM/62e0IIaBH13lYdsro4J2dK0Y7GyenWbHeehq5IZJH4nwrjk
	20lMS1VMSg/9E8DjU6FKORmMWPxy04jLZcxDXc9VjDdggwIgXJFYpTUb/ZpU8HDpdtrttwNmPTZ
	y9rf/z4AII9hpGbPl1+DEseDes/STv4Tu1/EMof1qAN07Y+sjEJjrFCVpZiJECACB/g==
X-Received: by 2002:a17:906:33c7:: with SMTP id w7mr2379635eja.191.1552578552246;
        Thu, 14 Mar 2019 08:49:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEUzeeE7MtdcRMwrTZozs3WStE7ROqFOrgcWGUx5djlYfQjZbIzxNHIcbq26Y/I7Njfa5x
X-Received: by 2002:a17:906:33c7:: with SMTP id w7mr2379589eja.191.1552578551372;
        Thu, 14 Mar 2019 08:49:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552578551; cv=none;
        d=google.com; s=arc-20160816;
        b=XCtQxNmG+3Mp24/GWlqrbgjzTU2ozT27VedDcAjFtW7VomRuUSPJuwQ9ghOMvZ06bR
         0GZ48j/dTXCfzEwDAE4RsGj15Q7H/RW7GI5EF7TCdIogYRUSWU8MaAdoKZ+pmYodQBDz
         ReFXvbjkEps3woPq4bPpM0XJoWqysjKXQ6b/AAW1P3l97nSifafLqHQ8V2wSOE7+SOz3
         zG9gbx/VTtbkjyp00fcJ+YD49k3JrRdwhDn0WHQ4usILVozOh7cnDx+rUVaGu17418TL
         PLNqLm0WDNGaruZnmPAwZXnTZHyL1w3dZ/t+w3kDxNsY5ew0agaeeOos5RFulBHwSEal
         oD9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UmwXuI0Tu6eH1ES7L3coBYvPrhIxuARhUcCL5HJ3a0s=;
        b=FlZJ3re/uZUNLkoEVGltZc7DhfqgMYVBbu6LwlZFGU84sv3lnO2GwE3gQvxfyDvzrF
         k9dyFjvHBXB5ZfRtTVTB+vAXLlC/+2SSupPgZ4RBnfOKb/9WBAHl3PLEHVHHmFoQ4t/w
         TxTFxWjW7b911dbaKr2og0rA60VS4I23CC3+XXlefEhpaFuqL0KqqscK5YnhbFX0pMQl
         gfIQZczWegxCsRrSRs0IYNLIZEzdQVxvGJUNuXh4XBDqMHggMiXR0EM18P3TyLZ0Wl9T
         p89KVQhDL5XyuqBsNOuu28e/nQWkm/KSZoiR7oLanouDLo3GGryenITspoMh7YnCOmVn
         SIZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id g17si143359edm.298.2019.03.14.08.49.11
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 08:49:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 66755457F; Thu, 14 Mar 2019 16:49:10 +0100 (CET)
Date: Thu, 14 Mar 2019 16:49:10 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Julien Grall <julien.grall@arm.com>,
	Matthew Wilcox <willy@infradead.org>, Nadav Amit <namit@vmware.com>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH v1] xen/balloon: Fix mapping PG_offline pages to user
 space
Message-ID: <20190314154907.wcwh5ricj6v7p23v@d104.suse.de>
References: <20190314154025.21128-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314154025.21128-1-david@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 04:40:25PM +0100, David Hildenbrand wrote:
> @@ -646,6 +647,7 @@ void free_xenballooned_pages(int nr_pages, struct page **pages)
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		if (pages[i])
> +			__SetPageOffline(pages[i]);
>  			balloon_append(pages[i]);

didn't you forget {} there? ;-)

>  	}
>  
> -- 
> 2.17.2
> 

-- 
Oscar Salvador
SUSE L3

