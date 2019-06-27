Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E900DC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91BF4208E3
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:06:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="m6y4j+Yl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91BF4208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F22B06B0003; Thu, 27 Jun 2019 14:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED31C8E0003; Thu, 27 Jun 2019 14:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8E08E0002; Thu, 27 Jun 2019 14:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 901916B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:06:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so6541276edr.7
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:06:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GNTzyha5uolkaXE/AKF7PBU/m2fQYAR8jso3b3bQxho=;
        b=TlULa3XtOVdybNW2od2mMDS+FegDISBG/DTdM3mGRahT/2kjUeh83ktGVEOpsBM3Rf
         9fuD7Kb9xQAqLjZfpGWvnXZBl2mcyqlXs0s3mWlvS+9EuUgfXlQzmnDJQu18L6Fq4TCJ
         w22/0PDJOaAUNX/ZAeIkn8DkXnXG8oGlkaAp5v2tgwBD05lzp22HkP+PWfBiG0OxJ9bW
         GHyzdFyXIZGg7nIcpXLxIrJXL3iqtB7f5itq4NlzchrFtwJEDiDkAB/7y0HvhOf4XxPq
         KJvIL+UtC3PMhLLD/F+BrAI/wvGzRfuiVncuS1x+I8a3YyUEWHN1ksm/RSRAvm4/Mlun
         57NQ==
X-Gm-Message-State: APjAAAW9tFl/Z7YkMdOld74OB3RGUnVoXYljcgRNkmt26sWAeMXVF600
	Qen7CYheZuM+4BTkIaMfgnXiz3ldF6dMdlh7yZV1NrIcxkKEfaz86nI5DBGFS3PaPO81JtnSeJB
	yXu75XobsjPNwx0oGzHp8yc6aZMo4YJeSx4GuTgn+ercVCPtBR8SaYT6oxx/3MJaOrA==
X-Received: by 2002:a50:90af:: with SMTP id c44mr5841851eda.126.1561658765071;
        Thu, 27 Jun 2019 11:06:05 -0700 (PDT)
X-Received: by 2002:a50:90af:: with SMTP id c44mr5841715eda.126.1561658763996;
        Thu, 27 Jun 2019 11:06:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561658763; cv=none;
        d=google.com; s=arc-20160816;
        b=uKXIBNs8hr4lF+j9sxltIc+UTfKZHarYPJOGjI1rwNSPyZIrvurHYUoUAue6jbNPD+
         znFN/1KORgige2Y32BALIB1Pnuep7MaMVbx49HL6jdxkPg9H4R9XQtSYXTzp8pqTuOFD
         YRZ1Mx306R/qJfX452PcoccVLoEcgGgUoa+SpQi587gSfFraFb/dTbG/ehku8KgrN2Gz
         T9glOoygaO8iYYU3vNjsRpkQK+nOjdT2BW9Xlji+AUVuQ7qnL1YveLqx2wvo95bBALQE
         jDA2glvAQWm/h8WqgH6ElVdtgN7jKONeduvf/jHccryWAFDaAkNionfq8NOjgoyE4cR9
         J6lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=GNTzyha5uolkaXE/AKF7PBU/m2fQYAR8jso3b3bQxho=;
        b=e6+8hJ1DKdd32Pbo9yeq/yVo1CWAYN68ESbNKBiJzQSvyWRF4pYXik4TflPu/0mGN2
         h/5glVTZYIP+OAbTyn14cjCtJYB20euslyfczgVOtRJs3VRS47xUXRkSlJj20wOjDUEW
         MBCBbh9/HEzYmzeFz8VpJd5tzvO0FA5I5UW8bZN9GS4XiAI93qOhhwtBjk6zSSVNcsSi
         qZSE9ANalskSekuqRyNuoAFFg5ID67OXWttoCB6uK2Y+OT+HuFKseamjTra/+gMjil67
         /iNUR8kedRrt/xSjXID7oJ9HmZ22VTKc1Z97KzKPh5Kh0bsO/Mk37U2iNJgtkvfse9ef
         Mp5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=m6y4j+Yl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g44sor2998446edb.15.2019.06.27.11.06.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 11:06:03 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=m6y4j+Yl;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=GNTzyha5uolkaXE/AKF7PBU/m2fQYAR8jso3b3bQxho=;
        b=m6y4j+YlgNsr629H/6PD1n/d7eQF/bkBheIl52SPCTGjhkZInu9kwhWyV6xo8kNYKD
         yW9xvLn6tcc/UhZ1t9w/7oCSIK6Vc7cAeNF1ujw0cWYoJ9L/EQaeAzVlDBsh5qQ+HxLB
         cH8PNBx5HRUIS74qnr91FI0M1RH074hNCCfXwE6ggsWmq6s/U7RoOlHwvpFF7HgPvyyw
         mjUyDP0Ghj3HoGxJp9lxEM2ZpSP6k9xFp1U/VO4rny6J3/W+RU9TtSfWSvoedcg/FZM3
         kNrp0BPWz4YjtLT0DHh2S/BgmzEt18f4tLKDNfLy9n9rAu/D4lhFEBrdEyZkl6qjrCpG
         +NjQ==
X-Google-Smtp-Source: APXvYqzGenvzx0Y0XnRI9xMYTAF7M9wkR56sl8+MbNVoy/EGzYm6e5vo9AYG/tf+nQsmZ+uVL9oupw==
X-Received: by 2002:a50:ac46:: with SMTP id w6mr6202710edc.238.1561658763449;
        Thu, 27 Jun 2019 11:06:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d36sm934170ede.23.2019.06.27.11.06.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 11:06:02 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id E28C7103747; Thu, 27 Jun 2019 21:06:01 +0300 (+03)
Date: Thu, 27 Jun 2019 21:06:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190627180601.xcppuzia3gk57lq2@box>
References: <20190627115405.255259-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190627115405.255259-1-minchan@kernel.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 08:54:00PM +0900, Minchan Kim wrote:
> - Problem
> 
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cached
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.

Maybe we should look if we do The Right Thing™ at system-wide level before
introducing new API? How changing swappiness affects your workloads? What
is swappiness value in your setup?

-- 
 Kirill A. Shutemov

