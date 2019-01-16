Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEEA4C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B1D5205C9
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 15:14:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B1D5205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D9A08E0003; Wed, 16 Jan 2019 10:14:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0618E0002; Wed, 16 Jan 2019 10:14:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBAEB8E0003; Wed, 16 Jan 2019 10:14:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A66BC8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:12 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so3972852pls.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:14:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=LNRE6+Eq/+hZAjeselLlEfXlpwEnZow0LUpD1bx2L5g=;
        b=VFAaTIhd/FGhjksEdoLKuBmfmqv7chB5AN0qwLB+cPnDjb8TlL9TfIBEcRrFO+bqEQ
         JNs9T4D+5ox7OVTa5QLz+qZj27z023vbQPe4fBD154uqoj6tYcHSAK9WkYeyMkgsOoms
         X/uMYto/w5se8g+N+xkKtiDeGWm908yQrZM/ODcve0CAOncJDp1mK1ZIitcOglOXtOqi
         SylALU4j3mxfmOxjPR9zbpx/pgWjBdQKYp9hMxwgWnoqV2LE4ozTopdQ4nQAnBLXa+k8
         hItktG/V7WGQFuCjrT/CZ4iSQQCcDMp/d9ssqrie7vbP64z4aS1GYpafFfYs2MAppfmY
         uvlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUuker/jCeZNFY6BI1y7/ACvT6BH6mn0am+S+39moJagyMZYnslox8
	LzC2whtkN5b+OLzbCIKrF+XnObT6EdEyZu5bff9UGnxvvTsIZwhUe0BD1kxJxXaWAWPcZr4WRlU
	+0iZ2uguz2kebNVNxR88IbceukDwbTigCcRBzDNiO351gO9V1InVfSDqU5RQdyD+nJw==
X-Received: by 2002:a62:798f:: with SMTP id u137mr10316759pfc.168.1547651652339;
        Wed, 16 Jan 2019 07:14:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN67v6jNp9jPYhomTocKTA1kPuU+RaSIigEGFhZR1uVIuwP4NfpFva3MxEKVQ/Z11Yk2HxrL
X-Received: by 2002:a62:798f:: with SMTP id u137mr10316668pfc.168.1547651651182;
        Wed, 16 Jan 2019 07:14:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547651651; cv=none;
        d=google.com; s=arc-20160816;
        b=tXVuEKoCjaW4Zxle6A5h6Lr5FNww3gvIhyfpsUIFFaC92GZWe/Io3NIgRLtFBLut4q
         1pk+6fw0UlETtGpbpX/jFiq1VeCiCqQqli81sMou5sXYEEF1z2/9ri9X06n/7rWAFjEu
         pL3doYh84QauiN9V0ZmAkw8jlP11fAJeyrWhL9hdNbBqdr/UT38Umz2480WeJLLcAhwX
         sc7/atdp/koioRpn5obkk27GW2VeCUuBRCpqH5rmrMV+9Xq1NPqpF/ykEzRSVAQpyBN8
         j2InWleiA6DZi3qhEwuD2plp7gfYuUlS38SD/xFamowvxQS9CbqTuKngJU1u3VPMkEz8
         mivA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=LNRE6+Eq/+hZAjeselLlEfXlpwEnZow0LUpD1bx2L5g=;
        b=LsHscRnujHp3URhiB9HqiHx6mIdhQvDJ5IuXLY03q9wvIOzBw6+iuEmDK7Amu3hbwN
         RDAsumLF56i6pM01NLqCYHdat18O6B/evzPPgxIm1JjI5ka0UEg3Seb92QYTsi3B+kLR
         kNrE1e7X3Jhb9TtjOrSoLGO5eyLd8HKn2FbQC1wTDomR6W4v5E6oURKy48x2ca3D+8cv
         5O++0VTEquJ6CZLE/0l4ht17dkgsEGuQFSCfHdNmlvKtah+OjkEuvkGRKnuM4X8+ruby
         5dPXyIyq7ZlixA7ESA0qoSEYK98vO3dFU3G60B0mBJxRlC5Oy4rbZz8mQt6vh2MeaIrc
         wOWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o32si1715942pld.407.2019.01.16.07.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:14:11 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GF9GTD085608
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:10 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q26gbsx7t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:14:10 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 15:14:07 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 16 Jan 2019 15:13:55 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0GFDsYN29294608
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 16 Jan 2019 15:13:54 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F3306A4066;
	Wed, 16 Jan 2019 15:13:53 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C613EA405F;
	Wed, 16 Jan 2019 15:13:50 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.226])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 16 Jan 2019 15:13:50 +0000 (GMT)
Date: Wed, 16 Jan 2019 17:13:49 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Dennis Zhou <dennis@kernel.org>, Greentime Hu <green.hu@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>,
        Max Filippov <jcmvbkbc@gmail.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>,
        Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>,
        Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>,
        Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>,
        Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Vineet Gupta <vgupta@synopsys.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS" <devicetree@vger.kernel.org>,
        kasan-dev@googlegroups.com, alpha <linux-alpha@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        linux-c6x-dev@linux-c6x.org,
        "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-m68k <linux-m68k@lists.linux-m68k.org>,
        linux-mips@vger.kernel.org, linux-s390 <linux-s390@vger.kernel.org>,
        Linux-sh list <linux-sh@vger.kernel.org>,
        arcml <linux-snps-arc@lists.infradead.org>,
        linux-um@lists.infradead.org, USB list <linux-usb@vger.kernel.org>,
        linux-xtensa@linux-xtensa.org,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Openrisc <openrisc@lists.librecores.org>,
        sparclinux <sparclinux@vger.kernel.org>,
        "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>,
        the arch/x86 maintainers <x86@kernel.org>,
        xen-devel@lists.xenproject.org
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of
 memblock_alloc*()
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
 <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <CAMuHMdWKPj-2Let44rmaVwh-b6kkGg+0cFPQ-+3k9LP86pB7NA@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19011615-0008-0000-0000-000002B1DF75
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19011615-0009-0000-0000-0000221DF943
Message-Id: <20190116151348.GD6643@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-16_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901160125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116151349.HS1FMzfqcz7lo2XxtqY1HoyXcGENyZExjcT0HMTV4Jc@z>

On Wed, Jan 16, 2019 at 03:27:35PM +0100, Geert Uytterhoeven wrote:
> Hi Mike,
> 
> On Wed, Jan 16, 2019 at 2:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > Add check for the return value of memblock_alloc*() functions and call
> > panic() in case of error.
> > The panic message repeats the one used by panicing memblock allocators with
> > adjustment of parameters to include only relevant ones.
> >
> > The replacement was mostly automated with semantic patches like the one
> > below with manual massaging of format strings.
> >
> > @@
> > expression ptr, size, align;
> > @@
> > ptr = memblock_alloc(size, align);
> > + if (!ptr)
> > +       panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> 
> In general, you want to use %zu for size_t
> 
> > size, align);
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Thanks for your patch!
> 
> >  74 files changed, 415 insertions(+), 29 deletions(-)
> 
> I'm wondering if this is really an improvement?

From memblock perspective it's definitely an improvement :)

git diff --stat mmotm/master include/linux/memblock.h mm/memblock.c
 include/linux/memblock.h |  59 ++---------
 mm/memblock.c            | 249 ++++++++++++++++-------------------------------
 2 files changed, 90 insertions(+), 218 deletions(-)

> For the normal memory allocator, the trend is to remove printing of errors
> from all callers, as the core takes care of that.

It's more about allocation errors handling than printing of the errors.
Indeed, there is not much that can be done if an early allocation fails,
but I believe having an explicit pattern

	ptr = alloc();
	if (!ptr)
		do_something_about_it();

is clearer than relying on the allocator to panic().

Besides, the diversity of panic and nopanic variants creates a confusion
and I've caught several places that call nopanic variant and do not check
its return value.
 
> > --- a/arch/alpha/kernel/core_marvel.c
> > +++ b/arch/alpha/kernel/core_marvel.c
> > @@ -83,6 +83,9 @@ mk_resource_name(int pe, int port, char *str)
> >
> >         sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
> >         name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
> > +       if (!name)
> > +               panic("%s: Failed to allocate %lu bytes\n", __func__,
> 
> %zu, as strlen() returns size_t.

Thanks for spotting it, will fix.

> > +                     strlen(tmp) + 1);
> >         strcpy(name, tmp);
> >
> >         return name;
> > @@ -118,6 +121,9 @@ alloc_io7(unsigned int pe)
> >         }
> >
> >         io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
> > +       if (!io7)
> > +               panic("%s: Failed to allocate %lu bytes\n", __func__,
> 
> %zu, as sizeof() returns size_t.
> Probably there are more. Yes, it's hard to get them right in all callers.

Yeah :)
 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> -- 
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 

-- 
Sincerely yours,
Mike.

