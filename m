Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B1AC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7DE21855
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:22:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7DE21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E09A56B0010; Thu, 18 Apr 2019 16:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDFA36B026A; Thu, 18 Apr 2019 16:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF6F36B026B; Thu, 18 Apr 2019 16:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3DA6B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:22:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so1993848pgk.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2a89JEIBhNjnMFpHIUB8tXT6s1IU6EnujuDo+qXWpHg=;
        b=e+73Znl/JsHItq0ZkEBdPQ8tgtp5derKiSV6Qfpnb/Fpc9b56U4ryzVTtXIqWJujiS
         bKfZ2PnSAcdv2MHEA/1d9CzWSWmRhoE0Cc0Ves7gAEaRr1qgFMRsa9qGUsDxlOV6OxVG
         WuLOIjg4Am26Ydp9dJIJ8pvysqTrH6Tu6ThgC+8yYsDIgzolDSdk2oRAVUVG97SRBgxX
         jTJNnhtGiCRS8P4siCxcOyPN7tZnwxTUzinjJBAVM3K8uhK4juDLEuABhhnl9IvQgTNr
         zaquoEkL8NGUjFe7fz0yibQfOqAI9pQD6I4pA03wuc18lOQVfIZ8oXG2G6dgwUfEJMB8
         02EQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUbcBjuOt4cSHhKfD+9xqYOnKnY+hl43ZGBmYymY6oFMcPKewwi
	TAnC2NVGZxDAGSlGG+JlhTIw3FIFCzsCdQFlMWIQZsyD176c92X4BoFikjMF+Vc+xnTUvLuu5X5
	ODTVpCApYfLsj3SFipi7BkUTIolrSOyOKnmKCNpUfmWG8AHaDTAumlQAkLIS05MboIA==
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr8269686plt.313.1555618947292;
        Thu, 18 Apr 2019 13:22:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt03N6LolFUgcAWzgCZFPsn5zO+BOt55B7URdDPx4+IeKXC7zDwB6U0rPCzvIlhPY7TFQG
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr8269641plt.313.1555618946690;
        Thu, 18 Apr 2019 13:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555618946; cv=none;
        d=google.com; s=arc-20160816;
        b=X5TNDiTPQcMlNioY8CsR+MXyOfcrDxv1xyO4+LFBFOBv+Ngoj1ERyxCS/b54HJcfGu
         ZRnwghYq561knHPzJO0mi1zfMEeihmzLue+dSHGdX/zCk14SnOOAH9eozHDgM8/XC+G1
         bB//2XD+HTl4Dtl8/qzgo2mRb8ST0oarA87lZmf2ryP3OsygEflpy01TjVPVuQe9FPPd
         6Om3fsF9uilns4ep4IGQiRR4SnpdlbMTTuIXzqEhzHTkTbZsCjCMWONbdEbPOutTx2uo
         M5Ru79ElegPppbyZadvYOoR7HF+8Sj6QYwHIm2cem6DjMgNePAfes3HVfcAkH/HMx8Vu
         /U0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=2a89JEIBhNjnMFpHIUB8tXT6s1IU6EnujuDo+qXWpHg=;
        b=Qec7btZh83NCfXJXOfJa3xDXuZbGggpfN5zu1gmp/4rR77wcaWxcusD2PkSjvIRITn
         bg7P0mVNjRMNbOXFLiTl1kDbCUq/5ZyzfZVRu8/Qt1g28HHJPAer40FZQZgSNtxlON0+
         p1XOgXbQtlqUlqBvKfIwL4F8AfvtTRRlloRmHPCKhnqr9u1dylb7paa+OWP74/JUuYDN
         H0bRLA27rvBf36wfBAg+55HJgAz0U8AXi/PWAYLa6K44HelqMnnmW71psJJxwKyN2KEW
         Y5ahcc7YwMBIS61J7kT34LkxRk7InFRZE6iNylMeiCbdiMAAcrM1RIYr1Wbw0SYOHkyR
         rphw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o15si420040pgf.105.2019.04.18.13.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:22:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tom.zanussi@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=tom.zanussi@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 13:22:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,367,1549958400"; 
   d="scan'208";a="141818813"
Received: from dytagah-mobl.amr.corp.intel.com ([10.254.15.29])
  by fmsmga008.fm.intel.com with ESMTP; 18 Apr 2019 13:22:22 -0700
Message-ID: <a8b9954d0c0a6cc4c213ff65c9ec3795ed0a05ba.camel@linux.intel.com>
Subject: Re: [patch V2 20/29] tracing: Simplify stacktrace retrieval in
 histograms
From: Tom Zanussi <tom.zanussi@linux.intel.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML
 <linux-kernel@vger.kernel.org>,  Josh Poimboeuf <jpoimboe@redhat.com>,
 x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Alexander Potapenko
 <glider@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, 
 linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Christoph Lameter
 <cl@linux.com>, Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov
 <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
 kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Johannes Thumshirn
 <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, Chris Mason
 <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com, Mike Snitzer
 <snitzer@redhat.com>,  Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>, 
 linux-arch@vger.kernel.org
Date: Thu, 18 Apr 2019 15:22:22 -0500
In-Reply-To: <20190418161342.34f4abca@gandalf.local.home>
References: <20190418084119.056416939@linutronix.de>
	 <20190418084254.910579307@linutronix.de>
	 <20190418094014.7d457f29@gandalf.local.home>
	 <014a7564d606b249a5e50bef0fedf266977a935b.camel@linux.intel.com>
	 <20190418161342.34f4abca@gandalf.local.home>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steve,

On Thu, 2019-04-18 at 16:13 -0400, Steven Rostedt wrote:
> On Thu, 18 Apr 2019 14:58:55 -0500
> Tom Zanussi <tom.zanussi@linux.intel.com> wrote:
> 
> > > Tom,
> > > 
> > > Can you review this too?  
> > 
> > Looks good to me too!
> > 
> > Acked-by: Tom Zanussi <tom.zanussi@linux.intel.com>
> > 
> 
> Would you be OK to upgrade this to a Reviewed-by tag?
> 

Yeah, I did review it and even tested it, so:

Reviewed-by: Tom Zanussi <tom.zanussi@linux.intel.com>
Tested-by: Tom Zanussi <tom.zanussi@linux.intel.com>

Tom


> Thanks!
> 
> -- Steve

