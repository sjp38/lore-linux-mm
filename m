Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD336C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:10:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DC542089C
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 21:10:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DC542089C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00E6B6B000A; Fri, 19 Jul 2019 17:10:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02BF8E0003; Fri, 19 Jul 2019 17:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18308E0001; Fri, 19 Jul 2019 17:10:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 978CF6B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 17:10:56 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id z24so7882886wmi.9
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 14:10:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=m5h/HWMkWy82+caoCNnuAqYR0Q1sxxFcpG9vAPTPhIk=;
        b=K/jwU7R4yhZz6bA0P4C/azZcYkNptBBTDk+qdOHW7gmHtrTQ90HfSfcP1MqrAlA+DF
         vRziOuSUAQma768f0/FJKTNLxQR1N/ZAPoSFgn54S+zCMGuWmY+YTNLNdLVRfJ2wZkLG
         AKQgIFPY/WITIeb7cpbii6kOI5RY+t+0vTcMIZppgd8nywiOEXY8yDXkChBBXrw3vD9h
         ggIwl6F//iOkibAG7KcahVKui1hoS5biR3i+WLHmVLrbwX8yyxfJX4eRb4jNlAPyROWc
         2o+r1PD/XKQjfAdMH9BELqy+AgsoYj1Pu9jT/USs9dXhWiWISxP5JzBLP5fVWW/keFtJ
         NuAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW9QJ7AHSxo6IeVmN2LSCZWHE0Mji4iKYNykL1D9wO7fRSML9xk
	bI2Ydmgh8HSoVGGQQ247Ax4mrjqVQ6fyn/1ERkV1NaX3KItCW4n6ibfESIoxHOatrvyybrXVzRq
	elsDC3NQfDJI2pfzdKvO0UeFKVFB1uisoZuauNUySsQmr+vDw8T4vQK7Rme8EFnvX/A==
X-Received: by 2002:a5d:408c:: with SMTP id o12mr54618450wrp.176.1563570656157;
        Fri, 19 Jul 2019 14:10:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjK13oPQvdxtIdeO5XpipdxHBJzIdbO2v8zlmeuBfFfyu8eTDHQZcmgTa4kQqzahSIsCR5
X-Received: by 2002:a5d:408c:: with SMTP id o12mr54618430wrp.176.1563570655502;
        Fri, 19 Jul 2019 14:10:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563570655; cv=none;
        d=google.com; s=arc-20160816;
        b=VhfjlVRLn8HsjpcXXCxdbQenlHCWGSK4ft1Y24ftXXea2bzyN9nfmcW1t+fzxl2b0V
         Dx5Y88aBexIQ17eu8UAJOhi6ob/mN8M5PGi1Tq+2Z68luMnopyudX6gyIvddAvZ8v8YR
         kDPd6EQl5zrMf1I0XpCuqf1Eq213/trlLv0bH8o7CYNaN98/UTKGmWo3jI+U6RPtLm93
         9sWOQqRtT1Nb7eIUWurFMB2qikvNWf5g/7tWPva6R8JZOdUd8xr/wEAPJ98nmyP6iugh
         DXuJ2EmRTLM6r9aDkYq3f6//BrGszePEhdpleG1f4Zs3VNnjCnKh/L1hsoB+1CqW0/2w
         st8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=m5h/HWMkWy82+caoCNnuAqYR0Q1sxxFcpG9vAPTPhIk=;
        b=hSQ+TC+ooDairGOzZ1WzOD132VxJI/YNBG6G7YKxaphdtaHG2S9iMDMpqesTGa2j3w
         +W09axofKTN0qCo+r58nYoi6EXokHGVj70bnv3ZafRLQguLkeTL6r9hAl1bhCr9qnY4Z
         GH6XOWT1pI3j7nh/8kS3QSUOBqGTap8dTOUxTz088rHlVdXSM5d650AjXAnzTw55FQAj
         n5FZNYGn1a3HcMT1ei6cxp2RoOAved+TkJvtL4W6wN2X4yXsCZKOW74FVW/ymqvdCjIb
         mJgTvEEUIoxVHmKD7qFKvdXQDahVZAwf7qM9oO/E/jK2SCU3i6alRWLwd6WrjhTUrVTx
         kYbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id y2si30635686wrl.110.2019.07.19.14.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jul 2019 14:10:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hoa9N-0004hk-UE; Fri, 19 Jul 2019 23:10:46 +0200
Date: Fri, 19 Jul 2019 23:10:45 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <jroedel@suse.de>
cc: Joerg Roedel <joro@8bytes.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
In-Reply-To: <20190719140122.GF19068@suse.de>
Message-ID: <alpine.DEB.2.21.1907192309190.1782@nanos.tec.linutronix.de>
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-3-joro@8bytes.org> <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de> <20190718084654.GF13091@suse.de> <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
 <20190719140122.GF19068@suse.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jul 2019, Joerg Roedel wrote:
> On Thu, Jul 18, 2019 at 11:04:57AM +0200, Thomas Gleixner wrote:
> > Joerg,
> > 
> > On Thu, 18 Jul 2019, Joerg Roedel wrote:
> > > On Wed, Jul 17, 2019 at 11:43:43PM +0200, Thomas Gleixner wrote:
> > > > On Wed, 17 Jul 2019, Joerg Roedel wrote:
> > > > > +
> > > > > +	if (!pmd_present(*pmd_k))
> > > > > +		return NULL;
> > > > >  	else
> > > > >  		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
> > > > 
> > > > So in case of unmap, this updates only the first entry in the pgd_list
> > > > because vmalloc_sync_all() will break out of the iteration over pgd_list
> > > > when NULL is returned from vmalloc_sync_one().
> > > > 
> > > > I'm surely missing something, but how is that supposed to sync _all_ page
> > > > tables on unmap as the changelog claims?
> > > 
> > > No, you are right, I missed that. It is a bug in this patch, the code
> > > that breaks out of the loop in vmalloc_sync_all() needs to be removed as
> > > well. Will do that in the next version.
> > 
> > I assume that p4d/pud do not need the pmd treatment, but a comment
> > explaining why would be appreciated.
> 
> Actually there is already a comment in this function explaining why p4d
> and pud don't need any treatment:
> 
>         /*
>          * set_pgd(pgd, *pgd_k); here would be useless on PAE
>          * and redundant with the set_pmd() on non-PAE. As would
>          * set_p4d/set_pud.
>          */ 

Indeed. Why did I think there was none?

> I couldn't say it with less words :)

It's perfectly fine.

Thanks,

	tglx

