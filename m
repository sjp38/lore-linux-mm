Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8F01C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:16:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AC0520B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:16:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="j+R1Ourb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AC0520B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23C766B026C; Thu, 13 Jun 2019 10:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EDE56B026D; Thu, 13 Jun 2019 10:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DD2C6B026F; Thu, 13 Jun 2019 10:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2A066B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:16:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so15605532edr.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zfhq9IiJVXNf+QOeCjoULwGTOfODIGNFGM6oVnHaXNQ=;
        b=YpejCVe6Mkhs/LvlWIOVmGOZfvQ21l7qqc/nEtCCay5gfA6HEU95Pbwn2cWT7hsvAM
         zejTpdHlRphU/XYfWLKs451lv/ogFAc0K8/WCagsvjCuqAkwhmKd+weTvXD3CVIWb8pS
         QE/xbCzi8fMnSedz9gqrLnokgz7mdm4lP8jlnhSO51k5/LD8P6hLuMhoq03i2xY4T0Xu
         G0ELXVjSRWDdFBZ1dqx/OnlSPTk9rRXMIIyFHo1emV4m326m233D//HlJOfS9aHPoS2w
         Vy0TNbUizuTz90LUEDmzfLVp7o1XGnTZ/1kdwPWIqHSRFSZNcX4o0Tqt/4BBlT44wtHB
         odrA==
X-Gm-Message-State: APjAAAUK2rzwRuNa7/uaviDiXcCOSxL4n0HLSWy9o51bL48jiNTt55my
	PSYlpa/DclschvAvSLbNqFcjr3YkRyPPryDKBeSx6cbWVyi1R4OHjJmy9VIQYNcxRoN5X/cDHUq
	9aBGRMB+THg+ZmkS5TNKJYlnOo2ZQN+gDSJexEJDEBJDmRzQTNGIpPiYZ941euSowfA==
X-Received: by 2002:a50:a941:: with SMTP id m1mr97120023edc.157.1560435379302;
        Thu, 13 Jun 2019 07:16:19 -0700 (PDT)
X-Received: by 2002:a50:a941:: with SMTP id m1mr97119868edc.157.1560435377902;
        Thu, 13 Jun 2019 07:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560435377; cv=none;
        d=google.com; s=arc-20160816;
        b=kEooixIPe7d6q/xH1kH2d0CQzlT8D6NhJpdpfvznlz+EWeFbO/uEwDGUJ70F6kNblh
         7nQ9XQtu5PdfHm3NAh5zu3a/lklgTDzSyic3eCn7fOCIxw6eKWKjngZ716b9qdYe7/Uw
         4xgSSdmVKXTwm/fjODVfaY/tA9CHN5IdNuL2ywAwekWCyemXycHJoX/feLQIFG7nKsL4
         1ET/1g1x2xVNEUEoKi7PjkF+dG4RnkeY8lxu2YW6UwiEU7X0zf1ZZeDk4Xu9kbgh4pCV
         Wv33ll3EyAbMcNUa5C0fC1r+7JnxcvnP6wORjDSj36iLCSDTb3/rga5sFPO7OBJJNpZ/
         pY/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zfhq9IiJVXNf+QOeCjoULwGTOfODIGNFGM6oVnHaXNQ=;
        b=iGfATmlWN4Iyv8AF1nSkU7iuBWKUzPPv5x6RFlFsykpJGEyeeLpc056qA6SVRYqMMf
         a+X9oi2gIaRmDu6IYoQ3COwkcbVgxNjhewfYiZ5AtV1JzZ6iZAE9M1hQENAYLC2b9tyD
         Vs1Ac1sI0ogjk1s85y00xR0dfBF9eYzWJ0bVn2MQkz9+BubNK76TaRRsn7hHWdePyKsw
         1/0FjP/zIz/xZEK2yeBWC4tJeVBwaNiBn3Nuqt0vZiDCSjisThaeemP/tYUHo0D5jG04
         s8T/JvJPGE+zuQIL5sb22Pz4dRF95VEQ4kvyXzhCK2k2qylXK1bp/hsU1FNrJDw+lur3
         T+3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=j+R1Ourb;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor148226eds.14.2019.06.13.07.16.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 07:16:17 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=j+R1Ourb;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zfhq9IiJVXNf+QOeCjoULwGTOfODIGNFGM6oVnHaXNQ=;
        b=j+R1OurbstKu0RisgFzmTieJxezTh38rMAEcoHHGEtWuRAHY1jSiKRk9u0yjhC/Ciq
         TEU0UX/Lfdt3ZseHghTCjBbkesFN74T4YpM2PvJEfxXiKZMDThB4PGip3lRNtVmusSgn
         l///05m1QHZDyuZ5bqmT0uWQn94nmyzU49DjM7sxe0xq1u+LUnjaJNyjK1+P6xBW28F2
         WUNQHW0TtRKQrSVzTYV3WKucjM22LUJS5YW7ltFSBls+Nio4gnjC0sQz/FRHm22uRuA7
         T1qgmKJp2N15PVRkMz6fiVWzqh7CUJjWpUtQjGzyoBGoqETZgipQIWtIcOztNGOghet4
         IBJw==
X-Google-Smtp-Source: APXvYqwr7X7rGeuhCIrwmc+ByVKc9dYLxDyik1ORrso48GpusnstzcW6+rBMZcR9NMFID6ciUHVHyA==
X-Received: by 2002:a50:b68f:: with SMTP id d15mr20174528ede.39.1560435377459;
        Thu, 13 Jun 2019 07:16:17 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c49sm374958eda.74.2019.06.13.07.16.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 07:16:16 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id ECB431008A9; Thu, 13 Jun 2019 17:16:15 +0300 (+03)
Date: Thu, 13 Jun 2019 17:16:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"namit@vmware.com" <namit@vmware.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"mhiramat@kernel.org" <mhiramat@kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190613141615.yvmckzi3fac4qjag@box>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
 <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 01:57:30PM +0000, Song Liu wrote:
> > And I'm not convinced that it belongs here at all. User requested PMD
> > split and it is done after split_huge_pmd(). The rest can be handled by
> > the caller as needed.
> 
> I put this part here because split_huge_pmd() for file-backed THP is
> not really done after split_huge_pmd(). And I would like it done before
> calling follow_page_pte() below. Maybe we can still do them here, just 
> for file-backed THPs?
> 
> If we would move it, shall we move to callers of follow_page_mask()? 
> In that case, we will probably end up with similar code in two places:
> __get_user_pages() and follow_page(). 
> 
> Did I get this right?

Would it be enough to replace pte_offset_map_lock() in follow_page_pte()
with pte_alloc_map_lock()?

This will leave bunch not populated PTE entries, but it is fine: they will
be populated on the next access to them.

-- 
 Kirill A. Shutemov

