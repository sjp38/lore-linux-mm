Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	SUBJ_ALL_CAPS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54115C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:24:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 181F020673
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:24:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VBhkUStR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 181F020673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FDF66B0007; Tue, 13 Aug 2019 07:24:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ADCD6B0008; Tue, 13 Aug 2019 07:24:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C40A6B000A; Tue, 13 Aug 2019 07:24:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id 6A83C6B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:24:15 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 08E3C180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:24:15 +0000 (UTC)
X-FDA: 75817170870.01.baby43_41fe126b9fb39
X-HE-Tag: baby43_41fe126b9fb39
X-Filterd-Recvd-Size: 3520
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:24:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=K5gbxcQPxrQYgws2hBkB1SH1ZLrBAecYkptVmkU/CGk=; b=VBhkUStRQ4A8I1CFq/DgEvG8QK
	mabjskg5FBYy57JI09/XJ+irmmluQEyFn85/SuN/45HNd3U/QuZsVBL+T1q44y1YuhmwXhFeFOIid
	5+TJqYzbYBR4TAQdkn+yPCLlhGjXlAQ8gSeXgktbYEHsVXCJu8vfkH90LYiZ3gbC2jrirPL9ZU49S
	/bvRIf8M2YA5toVEmvi1MpyRuNiS+3/VfzBQLmxvSpGFqj7t8TBqpby1yVIj97hYNPOiRJd/2Xg35
	YvvqIbffdEJSygJyMOOoqy74tKwa9u0wy1prWkxOhDCrSmHHMkfHeNaDXuascaWKuA3U2Y6cCpTEG
	zW2hQB3Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hxUuO-0006tv-Eu; Tue, 13 Aug 2019 11:24:08 +0000
Date: Tue, 13 Aug 2019 04:24:08 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?Q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
Subject: Re: DANGER WILL ROBINSON, DANGER
Message-ID: <20190813112408.GC5307@bombadil.infradead.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
 <ae0d274c-96b1-3ac9-67f2-f31fd7bbdcee@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <ae0d274c-96b1-3ac9-67f2-f31fd7bbdcee@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001469, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 11:29:07AM +0200, Paolo Bonzini wrote:
> On 09/08/19 18:24, Matthew Wilcox wrote:
> > On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r wrote:
> >> +++ b/include/linux/page-flags.h
> >> @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
> >>   */
> >>  #define PAGE_MAPPING_ANON	0x1
> >>  #define PAGE_MAPPING_MOVABLE	0x2
> >> +#define PAGE_MAPPING_REMOTE	0x4
> > Uh.  How do you know page->mapping would otherwise have bit 2 clear?
> > Who's guaranteeing that?
> >=20
> > This is an awfully big patch to the memory management code, buried in
> > the middle of a gigantic series which almost guarantees nobody would
> > look at it.  I call shenanigans.
>=20
> Are you calling shenanigans on the patch submitter (which is gratuitous=
)
> or on the KVM maintainers/reviewers?

On the patch submitter, of course.  How can I possibly be criticising you
for something you didn't do?


