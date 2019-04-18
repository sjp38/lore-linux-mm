Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5F46C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A86D20652
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:48:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A86D20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E1C46B0005; Thu, 18 Apr 2019 17:48:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 192AF6B0006; Thu, 18 Apr 2019 17:48:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 081276B0007; Thu, 18 Apr 2019 17:48:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBAD46B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:48:53 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o34so3273083qte.5
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:48:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VpB6rB/1iZ/kHIV9FIiDqF3Lo4EXh7OavN1Z+E97aKs=;
        b=Bqd3OUy3cMipVcVGWmBok8TlW5CRHAYhwDL37vGoSIlTqWwJJqPLpPZ5DWQsMNPQUk
         L5bv0Qpfiw/DqyqF6TjES8KSQux7vEDg45fSEtxg5ncPEbKx9atn6BPa9mEHjjDoW+aK
         CrNqwvwQ6rDPZAyDgyeKB0uxZOdKg226Lp9Iatwbb1vfQi3lht0HGQ3SrVo3dUIOTrXt
         7jRQewwhwWCZWYrvnmqeOlaMH8Wwf83nZI42/9bCk7Lx7MbatG8d+XAvbZjDaQcYtF0v
         fWnuLV+m5kt4cujmkewH0expPyqoTPPxoTbqP2NTM9J/AVrCaio1jW8FNACiy+50MlfI
         MqdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURbzrqtLQHYyyHiF7wXJZwtcEJRj77xGzncWpEv3+QEAmRzMrR
	65sI4AeWSAjLZRulZQyOPupTl298kbexaltxuSwjb0ll8BR/hLUpBg6EjEZL9ZCim9C44N7IvVp
	2Prjliqc2WQ+y046K+ksSN6v8KZq6I1b0MTmviiqFoNkoMeRuJg9aPWO8coCz7+RgrA==
X-Received: by 2002:ac8:355c:: with SMTP id z28mr352286qtb.286.1555624133691;
        Thu, 18 Apr 2019 14:48:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybGVRKVwGcvxBBV6qjQwIs52pufosU2630lnfEEqU7qifiB1Jjwp7gy9lLcJbjYar8k1Y6
X-Received: by 2002:ac8:355c:: with SMTP id z28mr352256qtb.286.1555624133215;
        Thu, 18 Apr 2019 14:48:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555624133; cv=none;
        d=google.com; s=arc-20160816;
        b=xuR27uTdlDE28zP0f/jVZrOZVpOo9ZyeCR7PKewrgT+2y5PlrUHO9X+zUyLSeZqQ+X
         sigesp5aJZevw8DZMYgFkIR/JpPgIxTGEr+yE+Xp4iaBtuuszI0qWX1IjyCuiSHFnXZJ
         C1CuGiii+5hzxF/sJ1cWrr14Eupb/oKRJpYeQ5AIk2J8bLUyjHbhI84Cwp/BeTugxg1F
         yBFw5Kiq+p6GZ58cQBiS+eCDpSbmWtkNtixNz1u4FZsy5WHVH0PnfiLqpV7AUVrgzCs6
         3IPhh7gsTr1Cifm7bh3Qdtm1EBfyNHcOHi7TLQronv24rwvCzA8mIQ6+O00HjsgpnH/w
         tKHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VpB6rB/1iZ/kHIV9FIiDqF3Lo4EXh7OavN1Z+E97aKs=;
        b=mUealIGJWSXaJ4ZxnmMKgVcFnLOC5cJMaK2RCvDgS5fric9qN8sm+PEPUkof1oLwPA
         PcL1hmi8/nLMUH7chxr+En1aTiSYO/a0JyHFs/FaZDgk6/tquitDwfngVyNAwfCzcz8I
         /XiWiPNToPiUTiROanNyk8/VXWzBomhXVhVXx1CozoVk9t67ACvh/IcvsRGFTQxF95eu
         uoOt7K4DVWgNMNZ18HdHvHkm8JK7MZnUQdK9eKw19eP47mui4yKoC5mNcB1c9t+Qf3EW
         WYWqMazTHAFVMbiCLm+fnL2tsyXyOWbdxWtC+nBTbIZhKqhSff6U/yujKrTMihNoft17
         T0OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d71si960957qkg.1.2019.04.18.14.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:48:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 03D1E7EBB1;
	Thu, 18 Apr 2019 21:48:52 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6A6F05C224;
	Thu, 18 Apr 2019 21:48:48 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:48:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 02/31] x86/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190418214846.GB11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-3-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-3-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 18 Apr 2019 21:48:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:53PM +0200, Laurent Dufour wrote:
> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT which turns on the
> Speculative Page Fault handler when building for 64bit.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

I think this patch should be move as last patch in the serie so that
the feature is not enabled mid-way without all the pieces ready if
someone bisect. But i have not review everything yet so maybe it is
fine.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  arch/x86/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 0f2ab09da060..8bd575184d0b 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -30,6 +30,7 @@ config X86_64
>  	select SWIOTLB
>  	select X86_DEV_DMA_OPS
>  	select ARCH_HAS_SYSCALL_WRAPPER
> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>  
>  #
>  # Arch settings
> -- 
> 2.21.0
> 

