Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C906FC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:19:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B07D2087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:19:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Yzt1J203"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B07D2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0A2C8E000B; Thu,  1 Aug 2019 07:19:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A923D8E0001; Thu,  1 Aug 2019 07:19:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9813B8E000B; Thu,  1 Aug 2019 07:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48A908E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 07:19:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so44562980edr.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 04:19:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qkKpSTDuuwbIMR/7MbiNrB08VgfKwqP+sli4OTfz1gY=;
        b=mZ5VIIK5Dt9hmuK+a5qszcPoYRmGyawHMM+7L1hfbPhsga54pQjJ2K4e3aidzWA2ZR
         YHL0rehwVE/ZAgmo6RMTJdfgMmjR/LM4kghWATNSWyWeLrXmefKZeABtLjs14Zkrvmgu
         fSN/Z8C9dt0Q48O03NNhOMgxFEMyzVev1oFkoCeadCerFOwj/EB0cFawhkmu61afewrG
         TCf51KBlnWhJiPX77MQYTGDJfaj4jJpGrVoMHtAEZPysBkjBsu6ryedOCzhQeyCOgacI
         t7b/YAtgmS0jSJHzdqrF/+hFSCbVg9lQagCYfoKoCM3YbjUZXeR/rUpfEac01UHcuEWB
         +Z6A==
X-Gm-Message-State: APjAAAWFqzJdVvyFd3HdnLMmKXXJ9y+D6T+lp3npx0pp4Gt1YmP7huQT
	K2F1ACt8hizkUdvK1M040pku7W/9r/KyvKjmPMJjjDe2CfTfzG0qVx+5nJoCp+sJmZ+ZB74xcgo
	jHz1g4D4gN85XCAfzNvuDrVaNTLclhqBrxmYnbXEQNpDCSYzOuZExuHjH+25/p08=
X-Received: by 2002:a50:ba57:: with SMTP id 23mr115008458eds.196.1564658388652;
        Thu, 01 Aug 2019 04:19:48 -0700 (PDT)
X-Received: by 2002:a50:ba57:: with SMTP id 23mr115008365eds.196.1564658387392;
        Thu, 01 Aug 2019 04:19:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564658387; cv=none;
        d=google.com; s=arc-20160816;
        b=0Y5oT2wFMu2TtesrjFNq8kHgrHNdFgQ2h5GcWHR9kZEeUzOy18rJZYIC8LXcoPdXCC
         JCChN2EK5X+fupL8xeSsPnNab3+LBSa1i4286Mazvi/NMvQAQT+HtHWEd5/NgdCA9o25
         kZ/WYT/HLu1J+DbKFdvJFF4AoxuuTI86cS9Km1ofAGEda169J8BbCVqRqiA8T8oS1GLO
         l7uNlvjLLkCprK9RzA0B1cAjJhAMoiywMGUoodHaGQcuj4sROlvPhZr6JKIo4ytnepcm
         UCaVchwYSbk2cCWI+nxG8a2QfXpZolhP/kUNk1iOq+s+653V+2rzaBQGVZAjk0PqFpUa
         TKOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qkKpSTDuuwbIMR/7MbiNrB08VgfKwqP+sli4OTfz1gY=;
        b=lha7CG/iWsTyji7eYG5mjDqza+994Ps1yhnSEs1y4X3jcRm6iYGnr52IpwtH8KcR7K
         j65nZpQCfAiICtiuY+yZ7x2Hek9dfZ2vUYG235IXpVvv0L6DpARKUQth0+klZzvJFmsJ
         mxQT6hQQK56wupiRltQ/oZ181X0fT5mzz9bOR0UxMjmUDNbwW8OdVtQPwvogsTpc5inQ
         QcbcRjKLrCcdkLWZN0l4eVQKIuT6LCtxNKIf+ua5Y6WdJGYxqsNjesut3mZrb3//5bfd
         eLJykItL414O30lyvz3pTQx5Df/e1y64ozr20MJCcC8B0HUtRrofh5SC1JIFTDtAXJzU
         TTaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Yzt1J203;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor54875961edn.29.2019.08.01.04.19.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 04:19:47 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Yzt1J203;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qkKpSTDuuwbIMR/7MbiNrB08VgfKwqP+sli4OTfz1gY=;
        b=Yzt1J203i5UaLb2ByniXCHSrE3OhEgnQfeu54s8xJucGCdyxoKsLbHGRhZsFRJpNrV
         F7zCOoVhdnnd+cfX0k0Bi0XvxD+Et5ZfpdlHyX/egg+VJ7fC6/tbb2Ewry0WiYu9rQ3L
         wvgU+2TdbrfP3wwSbAVAtW0RUhVq4hOugmAZZrv8MT05kS4Eek87hzHHdcs8XxpBLYn0
         7615oJ4D9zlLCIcJPyWyfvwwGm9vtX1ys+2UvvDqJQHTIcqwtjRDolSm3K57UNVyW7OO
         BUDrc/ihfpfHmn05kCOru0irD6vVDgUhNNu3ncF+VJIGNavENV4OEmyrirRLZJuVEgf9
         uiOg==
X-Google-Smtp-Source: APXvYqyF6SX0CWzPPaoMgH0374aYW1XGVWRamvSqB0icTKG4hTO5BH/o437WyHbZv3Vt63NUESQFzg==
X-Received: by 2002:a50:89a6:: with SMTP id g35mr116231607edg.145.1564658386729;
        Thu, 01 Aug 2019 04:19:46 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id fk15sm13004072ejb.42.2019.08.01.04.19.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 04:19:46 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id AF846101E94; Thu,  1 Aug 2019 14:19:45 +0300 (+03)
Date: Thu, 1 Aug 2019 14:19:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, oleg@redhat.com,
	kernel-team@fb.com, william.kucharski@oracle.com,
	srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v2 0/2] khugepaged: collapse pmd for pte-mapped THP
Message-ID: <20190801111945.t5jw3vivvfun4n27@box>
References: <20190731183331.2565608-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731183331.2565608-1-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 11:33:29AM -0700, Song Liu wrote:
> Changes v1 => v2:
> 1. Call collapse_pte_mapped_thp() directly from uprobe_write_opcode();
> 2. Add VM_BUG_ON() for addr alignment in khugepaged_add_pte_mapped_thp()
>    and collapse_pte_mapped_thp().
> 
> This set is the newer version of 5/6 and 6/6 of [1]. Newer version of
> 1-4 of the work [2] was recently picked by Andrew.
> 
> Patch 1 enables khugepaged to handle pte-mapped THP. These THPs are left
> in such state when khugepaged failed to get exclusive lock of mmap_sem.
> 
> Patch 2 leverages work in 1 for uprobe on THP. After [2], uprobe only
> splits the PMD. When the uprobe is disabled, we get pte-mapped THP.
> After this set, these pte-mapped THP will be collapsed as pmd-mapped.
> 
> [1] https://lkml.org/lkml/2019/6/23/23
> [2] https://www.spinics.net/lists/linux-mm/msg185889.html
> 
> Song Liu (2):
>   khugepaged: enable collapse pmd for pte-mapped THP
>   uprobe: collapse THP pmd after removing all uprobes

Looks good for the start.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

