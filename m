Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D612C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:30:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC33421900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:30:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OH8NebHD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC33421900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69E836B0005; Fri, 22 Mar 2019 17:30:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624DC6B0006; Fri, 22 Mar 2019 17:30:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514946B0007; Fri, 22 Mar 2019 17:30:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 326EC6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:30:48 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w11so2795619iom.20
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:30:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Wgnh9GZfm6qdLmvZgnj3r3+BNlXkGOKn5T8ZaWKJok0=;
        b=ah7A+ec7w0ZUDh2KdpOnjAAKsfcMKXX7M6MABz2NgwJgtsMvX1504XTwZZIqkB8VBD
         EEn1u5UCOvGYakUgKUVxiwQ8y3o7st2RE1Y33HONG8fMYgoStQcEzo79BPEKFVN8wlh2
         Y9FQJ5Bms38NM3kl6a7fdnEW99LzW2TdOGt2qvNveusDUMHFjDOIVHoOZ4gLsuJP923G
         8URsBkw/nvcUfuRSjJxLTEYSg4BOLxpdnHESR+KpZBmGXrWd1wYPl+cKR0hcIi7HCCfa
         JIJptws0AehJwlMtCp86Tj7BEmgHFb1vPavg7xHMd3/T0xfov3/ptozH02SMhgKZXFDw
         naWQ==
X-Gm-Message-State: APjAAAVJAtJUmVFv35wvV3NQ6OJUUvM2aZm92cjW5Fy6o7lyAhGahrzB
	HjcXo4Rw85/BeYNBFx7d7ss/KxhXPV4RMLdw3MKVY8vJ4x6nqLS+4UZ/3AjTVGJleiRV3uBuuxL
	OENhmCxAG4zbSIhYJE0n3Hu8iKE1JYpuCHiqxW2yIa3uzXTbC1hI/Ho/p19IMO0eMKg==
X-Received: by 2002:a5e:8e4d:: with SMTP id r13mr3480209ioo.80.1553290247990;
        Fri, 22 Mar 2019 14:30:47 -0700 (PDT)
X-Received: by 2002:a5e:8e4d:: with SMTP id r13mr3480180ioo.80.1553290247495;
        Fri, 22 Mar 2019 14:30:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553290247; cv=none;
        d=google.com; s=arc-20160816;
        b=yW2LCnEr77ULBVLe0qFYhQHuYifvv4fO2+F+U18b55gWkQY7JZxwXIfhpd1jzA3Nff
         2/ttLNpxrlOb+57HNRs9VoaXO68jNO5aNMneqRMhWL+K8NFdZsLmPoKkBYTQ0DOWBlYu
         3AcDTtgl0kk0FjZfXOk6Kmwi6WgQCOK/tdzKVAMtnjvGe3jiR9/yPte+FR5qvHzqL7+0
         oEfwQlA5/ULKmMVyDErl+hkYxV+QEUAi/Bp+S6Owtje27nwwTTRZv06DsN2KUY5yIIoL
         L+tLB7aLmRksF+8XaZrLJLcDNhGvdDJ8V+xuhH2ATlmU89y7Ot6MAu3oF1YHNiZ3IobD
         AR4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Wgnh9GZfm6qdLmvZgnj3r3+BNlXkGOKn5T8ZaWKJok0=;
        b=u8E+UZpPoQ718EMV7p5QL2vbyirRZnHl5lG/Bmkp9r94EyuxurbExGlU9zdi6pVNbB
         rYHPBAK8BkeLFX4xKvUGopm5d99rdGCsHCCjnBDQ3Vcv1XuXXJx5I2KKkTEUwG8ZWlUv
         Yz1VhACj771fXtzjcqCL+vsd22nMqxkR2JqAIGqENsGVIlPf9YjyNnvizdOCKGCnYyvM
         8LGRc0NNBSOs926OhIZzwyqox3fZRCusnkj1iMR1Y47tvn5FLRPpGghWIih+IzepSvSC
         kkp8LKDDxB+yziG8x4T6JelIxLyYXBf0TVIPVImBNhjN2khRKkfcjHXSNjw2Stictvfr
         iZSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OH8NebHD;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f188sor8510787itf.12.2019.03.22.14.30.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 14:30:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OH8NebHD;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Wgnh9GZfm6qdLmvZgnj3r3+BNlXkGOKn5T8ZaWKJok0=;
        b=OH8NebHDunzRV5JGQub2VtJ7qq4h4earirMR6lyAD1tbndqgaSQo6EHAFa1XOmj0Gs
         dVcO4mHB+I8Gzjx2PQQrJytnVorWQ136649AIwDqb+OrY0aZhZe/CAiDgikXseWKBQG2
         FkOiYPQ3ReZiCpOVfobxEopPeTsjWAbW4arVQm7GeTBum/QFo7st3RTKFW/k4BUo6iKi
         qqrOWnIunmKP+BcjLSDh5OjjWDpxn9ZH3R47GB9vvFeHXdgr8SGbrbJmFBbpxMtnf7r8
         gcRkEbTPG+V6sm+ujH2atRnCWCKSY69YXpLKQ3Gjo/8PWZNT9d+9uu3qs6PBsKPI7PrA
         gBBQ==
X-Google-Smtp-Source: APXvYqwmWYd90xIyw8yRh2ooXx60Z7HEDF1dbzChi7O8iR8by0Ikm8lKRK2GZFAQJ/A+sEyAwZAwm0xNODtGjD6Sum4=
X-Received: by 2002:a24:21d5:: with SMTP id e204mr910352ita.56.1553290247101;
 Fri, 22 Mar 2019 14:30:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-3-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-3-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Fri, 22 Mar 2019 14:30:35 -0700
Message-ID: <CAA9_cmcs+kUMA=j2UYwSRpEo+NMktTv5Od73fS-E9wxVr_v43g@mail.gmail.com>
Subject: Re: [RESEND 2/7] mm/gup: Change write parameter to flags in fast walk
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> In order to support more options in the GUP fast walk, change
> the write parameter to flags throughout the call stack.
>
> This patch does not change functionality and passes FOLL_WRITE
> where write was previously used.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

