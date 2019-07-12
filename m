Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA6E7C742C2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:37:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70A94208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:37:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oSDuCh7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A94208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 235358E0154; Fri, 12 Jul 2019 10:37:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E6648E00DB; Fri, 12 Jul 2019 10:37:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D6288E0154; Fri, 12 Jul 2019 10:37:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBC7D8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:37:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s21so5282984plr.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:37:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=54oSlyGRTEGiDyukqk95xO7T1K3/REJa8jWyRuvSrnQ=;
        b=hEK3Ww/V0n4ZLNSxowR8+8+7PB2Oi3CCBoPyKt5t6AqXDFZIOgwHbfrmra4XQigCAH
         ZHko3hPEKVYGLsFrlZgRHvv94I37cOLE8NJrWG3+nTRq+r5rilJa5Pk5RlNDf6SrpkdD
         jngBRx98ArPEW1GTo7V3xnylQMQks/GV3Nbcr2j0frsDUIU/3YzcOpEDYNK0Iybl5Ut0
         oEMbudT2Pz+WSOxg+Sl9apqH34TsWGWOjK74UHiM/lIuIa96C7QGfOqScrb2+zuFn5D8
         KmcpifSeo/CRJyauG+aANKj5ma5Md7YI2hDfgi2+xkO3Q8GX1dSQdCSoryka1pLQc38X
         KCsQ==
X-Gm-Message-State: APjAAAUa5bCysNhVCvRbjhf8/3+bXKifaQD2O46SKIFZm1ricoSZXSde
	A+cMukHLzYDhK49dsTRywAEFkS0UvO+dRZTL3uhj7QDKMHdCcAu/g7mvJe1PXLCSuY7M8m3QwPV
	nCMz/Q2sTdWhQwcOst+JV9Xvno05OuUT/u+5iC7OHxZNxEbVwJtb42h5y/2wEmqGjpw==
X-Received: by 2002:a17:90a:3590:: with SMTP id r16mr12354221pjb.44.1562942259395;
        Fri, 12 Jul 2019 07:37:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0x7MIDB22LDeRPwLWHnVVruN5gvcTiX6KhRnX2x/417eWuDDeX8dZPcbyR6k8HP9KhyNB
X-Received: by 2002:a17:90a:3590:: with SMTP id r16mr12354158pjb.44.1562942258713;
        Fri, 12 Jul 2019 07:37:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562942258; cv=none;
        d=google.com; s=arc-20160816;
        b=v5qAzgmzqoRfbbrt3ueWTnRQnn/HEWCFwMigMSrqjfYTOxW4uoE6zqL6HX5t0PV+2J
         uOdtsuVq0g7lL7X26D53bjhXqLZzaYGucLQoPzFvHI3jnfXF6LBJF5J0tTEliJ3TEh17
         quQMBgNcB4nsaEsBO/rjkxC0Mj66t7gBdq/NAkxT8Z97YlM1f90TW7E2nT5Rtt91RJMV
         w9+9wdjVuPDkpSMat6KQ+OG+FHs4Ie9sKitG9ETzVkSwVfAyMp2hOvCem1z5JF1ZarzM
         D/9U/hk82FpuhAZawdxMY/YrtAC+VZBAED+++4QW8BxxpZ41gBREMPqUg0B0G4Z097PP
         vaFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=54oSlyGRTEGiDyukqk95xO7T1K3/REJa8jWyRuvSrnQ=;
        b=AGx6aPaw1KzyPUdg2+FNFfc8uMF26/ozKLW0E4ymjPa1jGF2RkDWIXewErqrMTck/5
         eSJryNRhZ3MUEfZ4u5ELeFqLpK2w/K0ZALU0pfoHN8l9hy7LpoS6ab0ap8YhMgxLJbwI
         RLZRZ7RK6SxIdU/x+YfII1epq4audJOmnzSVgJ/V6exjU667xFll7TIVLlQxCOOSBkUd
         wc0jlhX8LsFz6KvE9AJFdN0p9u5Fx6lx3Czsns6yRBOx+md2tEpz1fCJt17/Qx+AfyjY
         sj29LycOXcBZuqhwATSdCTFKsn4PNm2W9VnKDQBnlPe3Mk3GAbf+6QzWFKkxsltM3NB3
         HF6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oSDuCh7A;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c36si8536598pgl.287.2019.07.12.07.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 07:37:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oSDuCh7A;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 997A82080A;
	Fri, 12 Jul 2019 14:37:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562942258;
	bh=Q0fQ8cIZPQQvRl+HqtEP93tavumXUJrRQeEzq/T0ZjU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oSDuCh7A+Xs42MXbXEieBsFty+Z7wObUN12OgwqLbOFW9oih/BmQBTm6f9I5uATLs
	 k3FxtcxVs2OyWqrnzMXueSISfTrdrWEpEWu7/gxb4zS9dLiXyM0oMjuEOYKj4+vyf3
	 slAytCaCOnyinCVXlJAAWb5BUeKOp+4U+rFpZcIw=
Date: Fri, 12 Jul 2019 15:37:30 +0100
From: Will Deacon <will@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Paul Mackerras <paulus@samba.org>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"x86@kernel.org" <x86@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Open Source Submission <patches@amperecomputing.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Will Deacon <will.deacon@arm.com>, Borislav Petkov <bp@alien8.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	Oscar Salvador <osalvador@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"David S . Miller" <davem@davemloft.net>, willy@infradead.org
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190712143730.au3662g4ua2tjudu@willie-the-truck>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712121223.GR29483@dhcp22.suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

On Fri, Jul 12, 2019 at 02:12:23PM +0200, Michal Hocko wrote:
> On Fri 12-07-19 10:56:47, Hoan Tran OS wrote:
> [...]
> > It would be good if we can enable it by-default. Otherwise, let arch 
> > enables it by them-self. Do you have any suggestions?
> 
> I can hardly make any suggestions when it is not really clear _why_ you
> want to remove this config option in the first place. Please explain
> what motivated you to make this change.

Sorry, I think this confusion might actually be my fault and Hoan has just
been implementing my vague suggestion here:

https://lore.kernel.org/linux-arm-kernel/20190625101245.s4vxfosoop52gl4e@willie-the-truck/

If the preference of the mm folks is to leave CONFIG_NODES_SPAN_OTHER_NODES
as it is, then we can define it for arm64. I just find it a bit weird that
the majority of NUMA-capable architectures have to add a symbol in the arch
Kconfig file, for what appears to be a performance optimisation applicable
only to ia64, mips and sh.

At the very least we could make the thing selectable.

Will

