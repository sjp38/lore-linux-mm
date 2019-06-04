Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50244C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BFA02484B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:27:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BFA02484B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B807F6B0273; Tue,  4 Jun 2019 03:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30CA6B0274; Tue,  4 Jun 2019 03:27:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F91B6B0276; Tue,  4 Jun 2019 03:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63F166B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:27:32 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d18so9647644wre.22
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:27:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=st1B52HuT/7YihyLKKQZYS2Flek9sk+ERc2S4b16eks=;
        b=Cbrt4cJecWZ+vVMgf/vsYmaSKEPSJTW9+lxLFnLFdOTlTBVXGELB/OQCVKEz5uK38s
         0P64NAWsIxJ4RJJL1OpAX3g7LWFD86zWSTxdi3DERu0CsMwy7PxsclTUuhWtIiB+a0ZH
         4q42dFyMvQKciT6NbXlRC0Bo0VCgYxZ9sU9Sy+M3iIipzZCLEMmAsTeGT/A1alz6Acqs
         E6EN3NwNEo3Nwdg6dGiLX2tBqCqwtm6cwGwHYDBJ7xe/iTEEW5+Dakj2mF/2ZIzO+4fz
         iTlsV1nXx0ylGgLJyXFqoa6TQVwm98Lc9m1Nps4wuhcCFIQ8Xe3OjXP7FR460w+JhKQw
         nXkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV1Eq7KwMVw0mm/uUemXXszQa7HbW6RBws2WlU62EzDPd7ZbdbM
	Kb8D+l18vRvFSYKhmVBqO7KmQVIcLmFAp0jVHHdw7+nX9YploC3D8xc6CG/vKBqahrq4ZewJryH
	lShWU0SHKnqHoPfBjzgVQUryCfgTsC2noOEzU4M7OgXM+2p1NZDOkYN8YsAieI7JW1A==
X-Received: by 2002:adf:e945:: with SMTP id m5mr5437360wrn.90.1559633251961;
        Tue, 04 Jun 2019 00:27:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmuWz6vhwSVLJv5v86OLa9mKv6iwYPXcQDN23X95cv+UAaMgd7FzDjEV86YM6ulzftbOGO
X-Received: by 2002:adf:e945:: with SMTP id m5mr5437324wrn.90.1559633251250;
        Tue, 04 Jun 2019 00:27:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559633251; cv=none;
        d=google.com; s=arc-20160816;
        b=o5MUpCfppjoK2RkIH+51pKAlWQ5tvJJZ/PDdyER826kZRMEe6J3lsujSG4O2snmelZ
         yc5vDGQeCIJfYdJOEAlBRDCD15g/FA8fQAAxv6IMVga21Takv8wG+Nbmn89dJUJljy6d
         6KIcB1qxfAa01kB2FytPeX51q8QMJSaYkxxDCVzrs5uA3TLJOsQZMx3jptXcPWxmuXKn
         NO3JOXzDHfzsYXAgGokGALl9uSwQVYSUgCPevItc/PQLh37UpF/2OCB+pq3O1CxZN2iE
         MInhsQWAUWNjk3xuDoD1S3iu0oPLu+87aVL2okAiDhNYVRovhorRpXbj6ggEa/e55a3W
         biaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=st1B52HuT/7YihyLKKQZYS2Flek9sk+ERc2S4b16eks=;
        b=g2m2okoP/44NtmE9ooaOfeEhc0WhtYxH7l6WJr/QUMxa5lscLylBtObaaTfIOGlpVA
         6UZ2bctSxTgI8O85ZJcK2MU+hY7DiUa34wyj7UoI5Va2+dvAHH+PAqFL6n5okhIp8K0I
         Nnwthwa8iGNJS8zUCFzcdSrnzMC4AzWOMp6jlpteoVmXkQB39bdWlT7wekA21SrDeSpw
         5JN0BPUGzEqWRbFAhHMeGFwy5yNzDPiiHjWO4MML6ALGysly56BAwZv3aSSnyh0Yfqwy
         YORdmdidVEeWgSqPohw/P6kerr3bWEBNajYyB3i6hnLsdd6JcxGNA01ET77MXUxBjxn2
         /HEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u11si12761934wri.248.2019.06.04.00.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:27:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id A57CC68B02; Tue,  4 Jun 2019 09:27:06 +0200 (CEST)
Date: Tue, 4 Jun 2019 09:27:06 +0200
From: Christoph Hellwig <hch@lst.de>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrey Konovalov <andreyknvl@google.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 01/16] uaccess: add untagged_addr definition for other
 arches
Message-ID: <20190604072706.GF15680@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-2-hch@lst.de> <431c7395-2327-2f7c-cc8f-b01412b74e10@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <431c7395-2327-2f7c-cc8f-b01412b74e10@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 09:16:08AM -0600, Khalid Aziz wrote:
> Could you reword above sentence? We are already starting off with
> untagged_addr() not being no-op for arm64 and sparc64. It will expand
> further potentially. So something more along the lines of "Define it as
> noop for architectures that do not support memory tagging". The first
> paragraph in the log can also be rewritten to be not specific to arm64.

Well, as of this patch this actually is a no-op for everyone.

Linus, what do you think of applying this patch (maybe with a slightly
fixed up commit log) to 5.2-rc so that we remove a cross dependency
between the series?

