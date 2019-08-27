Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD2A8C3A5A4
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:55:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8932A206BB
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 01:55:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8932A206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0056B000A; Mon, 26 Aug 2019 21:55:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44FE76B000C; Mon, 26 Aug 2019 21:55:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3656A6B000D; Mon, 26 Aug 2019 21:55:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0240.hostedemail.com [216.40.44.240])
	by kanga.kvack.org (Postfix) with ESMTP id 17FAF6B000A
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 21:55:06 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8C2CD82437D7
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:55:05 +0000 (UTC)
X-FDA: 75866539770.27.song90_83a9481f76649
X-HE-Tag: song90_83a9481f76649
X-Filterd-Recvd-Size: 2909
Received: from ozlabs.org (bilbo.ozlabs.org [203.11.71.1])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 01:55:04 +0000 (UTC)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 46HX4f0vmjz9s00;
	Tue, 27 Aug 2019 11:54:58 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: David Sterba <dsterba@suse.cz>, Nikolay Borisov <nborisov@suse.com>
Cc: dsterba@suse.cz, Christophe Leroy <christophe.leroy@c-s.fr>, erhard_f@mailbox.org, Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, stable@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2] btrfs: fix allocation of bitmap pages.
In-Reply-To: <20190826164646.GX2752@twin.jikos.cz>
References: <c3157c8e8e0e7588312b40c853f65c02fe6c957a.1566399731.git.christophe.leroy@c-s.fr> <20190826153757.GW2752@twin.jikos.cz> <a096d653-8b64-be15-3e81-581536a88e8a@suse.com> <20190826164646.GX2752@twin.jikos.cz>
Date: Tue, 27 Aug 2019 11:54:57 +1000
Message-ID: <871rx74bke.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

David Sterba <dsterba@suse.cz> writes:
> On Mon, Aug 26, 2019 at 06:40:24PM +0300, Nikolay Borisov wrote:
>> >> Link: https://bugzilla.kernel.org/show_bug.cgi?id=204371
>> >> Fixes: 69d2480456d1 ("btrfs: use copy_page for copying pages instead of memcpy")
>> >> Cc: stable@vger.kernel.org
>> >> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> >> ---
>> >> v2: Using kmem_cache instead of get_zeroed_page() in order to benefit from SLAB debugging features like redzone.
>> > 
>> > I'll take this version, thanks. Though I'm not happy about the allocator
>> > behaviour. The kmem cache based fix can be backported independently to
>> > 4.19 regardless of the SL*B fixes.
>> > 
>> >> +extern struct kmem_cache *btrfs_bitmap_cachep;
>> > 
>> > I've renamed the cache to btrfs_free_space_bitmap_cachep
>> > 
>> > Reviewed-by: David Sterba <dsterba@suse.com>
>> 
>> Isn't this obsoleted by
>> 
>> '[PATCH v2 0/2] guarantee natural alignment for kmalloc()' ?
>
> Yeah, but this would add maybe another whole dev cycle to merge and
> release. The reporters of the bug seem to care enough to identify the
> problem and propose the fix so I feel like adding the btrfs-specific fix
> now is a little favor we can afford.
>
> The bug is reproduced on an architecture that's not widely tested so
> from practical POV I think this adds more coverage which is desirable.

Thanks.

cheers

