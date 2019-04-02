Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49193C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:44:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A49207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:44:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A49207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A250F6B026D; Tue,  2 Apr 2019 19:44:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D4896B026F; Tue,  2 Apr 2019 19:44:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EABC6B0272; Tue,  2 Apr 2019 19:44:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 415086B026D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:44:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d2so6469819edo.23
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:44:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TTT6iuirms5imogJ/97iiAmgMiJKj0rpDKpDhUB/tlw=;
        b=DCEqMIUNC+DNhk9T87EooXO6WBmr0YG0RCc4Jh2f1TgocNfDe1Z1Co2/RnwH3YShJo
         PbF/bSG4zMwd+vFZYumogk/rcDTdlF/5C/2bmmYeTsttzWSXOnYJq8BTcEUR45P6Agxx
         QaeJBiRnGhWrrPINSr/Sb5eMdS6urBFvGc9vQhCrxMVzH9gKOsmC5qbsnUlKtXD2d+JD
         wYel7UNdSssL2K/DlZQQv24UPp7oh+S7cUbXUgI8SaDTHH4CRMXFenSwk/d/yl+pMs+8
         gdMxxzIPecGlxtoJDtU2mowHbDitByIei3z0Gmq62zIPcJze+vlDhVXdATRzeT6OI7FY
         Y+Fg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: APjAAAVqCxVOkz6ObcrHMO/me6tJzDe6ZK475p2bY/8CQpCLGEKs+fFf
	Jb1Eoqb7zyxdGjqnAbOizkzb/quocHFqFNAf/P7cnvSW3tGpc0Oy/noA10cDjYirr2JHNhfqr/W
	jVH+uKGnriUlqzEr28iBfUxzrkQrGx7jH7GGcryR3yYD3jkM7RaINdfbZs+suvsQ=
X-Received: by 2002:a50:b4af:: with SMTP id w44mr18765085edd.179.1554248649858;
        Tue, 02 Apr 2019 16:44:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN+WKMETevtDaD8IGQvQtoCjQcURAKnpx0nO5Jz6W6cSfFCxS3wHttt63BorlNvb2qvB3D
X-Received: by 2002:a50:b4af:: with SMTP id w44mr18765061edd.179.1554248649175;
        Tue, 02 Apr 2019 16:44:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554248649; cv=none;
        d=google.com; s=arc-20160816;
        b=utDYTTpuPQ84vQ8QIDVf7a4uOFPh5EFgU0IUT2ORz7vbb8RixdhWb/ra/3sN1IDtn8
         PwC8JbXYQKb+psuxRx0rF3Tm/3Zr0l/i6fMjSHsELKZdJqo9gQ0G1aRV2YSSYfXoN94n
         SKKgqQ616UNfZU5RGsA9RpN6Z23hOi2k7jpw9ZJrKlzqk/+3JaPRoioSfgogx2eH0GdX
         tESlqsJMMb8VqqArSkVNwSfhlkuQsK7eECrknGVKm9c6O8BTB6G6pN2hPpQHxkoo9D+U
         5SYlVjqlQOuf1FgNnpYnpRRXkuIedbymzRZDweOdrgcs88D7fP2LmywnZMLuu4M2Iv6Y
         2nYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=TTT6iuirms5imogJ/97iiAmgMiJKj0rpDKpDhUB/tlw=;
        b=Ti2EsslfVaA0BHnIIEJmCHE+OQWP2LcfQuIYYuD/Vu53azxfcG6xxhHzyMDHLUlox8
         jpJwXBV2o6VcS3R2ZGK8an5K2uN5bquLDGGxsFm2j90kS6tQSFJoQgzrIZzB/ZY2gbze
         lnSlyp9ivE9Gaalf+lhwmeSarHuuEC5eD+1Fa17/dVURSex0tTJXEMj66p3/15E+OLoN
         6rVbmr7NIFaywhLbxAqy0p1XUQBktf7kXv6Hopc7qiZfz5pXObAH4mOcuwMbnhSKnwxM
         mPfaU20tUn8PzixHZygyuajFnuBnWgvbwqmLp7nliDIy86oR0vovkHIRuspzUHt7/w/q
         /mGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m26si3455097eds.252.2019.04.02.16.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:44:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1ED2DAC8D;
	Tue,  2 Apr 2019 23:44:08 +0000 (UTC)
Date: Tue, 2 Apr 2019 16:43:57 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Lameter <cl@linux.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Moritz Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>,
	Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190402234357.tn3tik4r7k6nbrau@linux-r8p5>
Mail-Followup-To: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
	Alex Williamson <alex.williamson@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Lameter <cl@linux.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Moritz Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>,
	Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <20190402150424.5cf64e19deeafa58fc6c1a9f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190402150424.5cf64e19deeafa58fc6c1a9f@linux-foundation.org>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 02 Apr 2019, Andrew Morton wrote:

>Also, we didn't remove any down_write(mmap_sem)s from core code so I'm
>thinking that the benefit of removing a few mmap_sem-takings from a few
>obscure drivers (sorry ;)) is pretty small.

afaik porting the remaining incorrect users of locked_vm to pinned_vm was
the next step before this one, which made converting locked_vm to atomic
hardly worth it. Daniel?

Thanks,
Davidlohr

