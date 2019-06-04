Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3CB5C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84B9124439
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84B9124439
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A1196B0266; Tue,  4 Jun 2019 04:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0524C6B0269; Tue,  4 Jun 2019 04:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5D136B026B; Tue,  4 Jun 2019 04:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD3986B0266
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 04:32:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so11911511pgo.14
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 01:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7FN1UgNuJG9+eRSIdJ5dIp7nJTtiP6BL6wkemJpMgzY=;
        b=d6WmZLaUKtxJ5pWZfzn4hczY1MwSwpl4YtOsW4H0DYrW4mRlMPJPETEiQ+AKelHTq3
         JTy4Ug99mA8oNaCXzKPY0CWpRCApscBCDZD+JLwrIFcYkBPKXYSVCz+vYOGOZVe9wtqn
         Qe072XA2kQU4v4ESdrtuCxwlHEHxLrjd5bn3DXUvC+//bMW5LhxVWYu0gvJoiClrKYAp
         aYi+Vjp4FFkuv3c9ZyyIkEXgCuo7BN2sShxRZ8iRKxn3XqrzpMu2EHhNXuUfyGe+9HpY
         lasmY/raaenV4WdjTel7eGJd50PuybvOvr4/KhsNDI/fTvQOLJ8UjsBjSM6eEHYMiaxZ
         FB6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU+4cgq7cpSmyyVbt5kIor/Bue1Au6wUhJ+hDfKQ8TOyA6uJXBG
	8jk2p3Oc+M1aphh3gV3d40CoGquKCH8Gj24qcWMcwM0gc4kF6QLTgGfaY8TZhH14TM93r5DaUw8
	8AsHCsQf/U1lQMjvW7kHXZ0b/q47DGYYbHc8TJKxAkCVYrCKpnPJCtR8kQeLwHobwfg==
X-Received: by 2002:a62:5c84:: with SMTP id q126mr10422172pfb.247.1559637148323;
        Tue, 04 Jun 2019 01:32:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoRWg/Sj8noLIzSOx1XUSNJ0PUzvwD6kJ/PuXdvXCExNUVdJ7h0YArkJfKlWiSS9VUz7Iv
X-Received: by 2002:a62:5c84:: with SMTP id q126mr10422120pfb.247.1559637147548;
        Tue, 04 Jun 2019 01:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559637147; cv=none;
        d=google.com; s=arc-20160816;
        b=PwxDe35YD1t2dTOSc65OA8kptA1iEdaGM3eRFBctvqhxo2mucAv+fx2bqAKOveAgTq
         f8s/LowFK/y99Y4oN0xnVz4MSH7v6FAabk7D9sWAb8oYgG9b0kXlTVPloaDRhnFWoB/I
         lLYDFIDRLvboYIfbU9ewSNEDBrUtzI2/yTsOsCkEoBMAvfPW3yG51pYDtJ+vhnqWVnYX
         3liyv+NmG5TH928ANn8tvZmB8Igq73A3c/PAFWsBH5lf8DVJI6mC48W894RaSmHdjVCk
         HXYYWtJuoBrHQMH/lv7G0ac/7tNpl3PRYO/q0tATtDdTNEOfbDRcHSiOHcCQUpPJgEEv
         xZaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=7FN1UgNuJG9+eRSIdJ5dIp7nJTtiP6BL6wkemJpMgzY=;
        b=yEt1FBKQK+ZfVjt4LU7uds4L9cLM8/GM1901SdC73qAi+/Pt5n3Z5HFrqTO0PX4NQ7
         Ml6HlTZw64Xb9UsVTH+DswBAGfWo3Cx+8U4yEJ4RdhC/QseOIW6HNhbQUR6O1AUHlz+s
         F7czEB6T1p1urGD8DNvk/80tOeJ1BFC5pA1W4RHCi0mEJKZ57LSDzgHMyOf846uvRtAz
         VrAg9TyNRn2qgDmT3LDTnrky/+ce3QGmtE4CE6NEyByM/Ly2JdsJ09vIumxlW/LzMzu0
         23rm2gToT7oMUK0/52TwQPzrIENYkn/YDpB0pMBslMKhTpn1UARMuisVJpYLRQuWUelb
         Qorw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 14si24289327pfu.76.2019.06.04.01.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 01:32:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 01:32:26 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga006.jf.intel.com with ESMTP; 04 Jun 2019 01:32:17 -0700
Date: Tue, 4 Jun 2019 16:31:48 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
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
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
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
Message-ID: <20190604083148.GA28403@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-7-david@redhat.com>
 <20190603221540.bvhuvltlwuirm5sl@master>
 <2ba74d1d-643e-7e22-acff-2b04c579b4f8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ba74d1d-643e-7e22-acff-2b04c579b4f8@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 08:59:43AM +0200, David Hildenbrand wrote:
>On 04.06.19 00:15, Wei Yang wrote:
>> Allow arch_remove_pages() or arch_remove_memory()?
>
>Looks like I merged __remove_pages() and arch_remove_memory().
>
>@Andrew, can you fix this up to
>
>"mm/memory_hotplug: Allow arch_remove_memory() without
>CONFIG_MEMORY_HOTREMOVE"
>
>? Thanks!
>

Already merged?

>> 
>> And want to confirm the kernel build on affected arch succeed?
>
>I compile-tested on s390x and x86. As the patches are in linux-next for
>some time, I think the other builds are also fine.
>

Yep, sounds good~

>Thanks!
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me

