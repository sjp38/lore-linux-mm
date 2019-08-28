Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACCD3C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 20:01:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 783DE22CED
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 20:01:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 783DE22CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EF486B0003; Wed, 28 Aug 2019 16:01:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A04D6B0008; Wed, 28 Aug 2019 16:01:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28F506B000C; Wed, 28 Aug 2019 16:01:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id 073236B0003
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 16:01:40 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9DE06180AD804
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 20:01:40 +0000 (UTC)
X-FDA: 75872906760.15.shoes30_48c77a1b96448
X-HE-Tag: shoes30_48c77a1b96448
X-Filterd-Recvd-Size: 2773
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 20:01:40 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9579F88313;
	Wed, 28 Aug 2019 20:01:38 +0000 (UTC)
Received: from treble (ovpn-121-55.rdu2.redhat.com [10.10.121.55])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E57925C1D6;
	Wed, 28 Aug 2019 20:01:36 +0000 (UTC)
Date: Wed, 28 Aug 2019 15:01:34 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: mmotm 2019-08-27-20-39 uploaded (objtool: xen)
Message-ID: <20190828200134.d3lwgyunlpxc6cbn@treble>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <8b09d93a-bc42-bd8e-29ee-cd37765f4899@infradead.org>
 <20190828171923.4sir3sxwsnc2pvjy@treble>
 <57d6ab2e-1bae-dca3-2544-4f6e6a936c3a@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <57d6ab2e-1bae-dca3-2544-4f6e6a936c3a@infradead.org>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 28 Aug 2019 20:01:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 10:56:25AM -0700, Randy Dunlap wrote:
> >> drivers/xen/gntdev.o: warning: objtool: gntdev_copy()+0x229: call to __ubsan_handle_out_of_bounds() with UACCESS enabled
> > 
> > Easy one :-)
> > 
> > diff --git a/tools/objtool/check.c b/tools/objtool/check.c
> > index 0c8e17f946cd..6a935ab93149 100644
> > --- a/tools/objtool/check.c
> > +++ b/tools/objtool/check.c
> > @@ -483,6 +483,7 @@ static const char *uaccess_safe_builtin[] = {
> >  	"ubsan_type_mismatch_common",
> >  	"__ubsan_handle_type_mismatch",
> >  	"__ubsan_handle_type_mismatch_v1",
> > +	"__ubsan_handle_out_of_bounds",
> >  	/* misc */
> >  	"csum_partial_copy_generic",
> >  	"__memcpy_mcsafe",
> > 
> 
> 
> then I get this one:
> 
> lib/ubsan.o: warning: objtool: __ubsan_handle_out_of_bounds()+0x5d: call to ubsan_prologue() with UACCESS enabled

And of course I jinxed it by calling it easy.

Peter, how do you want to handle this?

Should we just disable UACCESS checking in lib/ubsan.c?

-- 
Josh

