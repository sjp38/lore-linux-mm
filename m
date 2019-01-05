Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29AE8C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 22:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE7E222BB
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 22:55:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eqx40GO4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE7E222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A9BF8E012F; Sat,  5 Jan 2019 17:55:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 232728E00F9; Sat,  5 Jan 2019 17:55:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FBC58E012F; Sat,  5 Jan 2019 17:55:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D448A8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 17:54:59 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id m52so17873081otc.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 14:54:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AWttGSuK6p3ZjKI0uWuqGI1eUFhgSNn7XCSj6cGkh3c=;
        b=SI/lBIrqiZSSaTuEDPzsYls/7MrEMtv5sbniKsJFICDWQqWxhiYZ49CRmdnmVqYCJP
         iwuoUEIleVbTtdWX+MUbymkemIodCsqaGcvPkNXc+q/V4CnBV0yP5BU++f4+EbD7ojG6
         yga1EwAnMYLdPXol+DM1UQE5e/AXO29C+Pl9Q2p7EYd1/8LlSx5O4F0oaKSCH+jB58lw
         fufVSf9pcIXkZkm3L6AyJE64s9pEcD8EPEz1mOGkHCuIzxL/oGx4nR+Xmo8BGmpXQ5qI
         fb21SCh62TM1CzN+QPVCiHCPVg07l4qgCxWNtxTWB0bw/CxX8tNVyZt0uT+GcxehVtqq
         MW8g==
X-Gm-Message-State: AJcUukcAzNPTtY7Nm8KJOu9oGUN0TFqhLLqiZXDvc0Wo5yXhLHJ9yumY
	MrexIiGu9gODFDbSFN6AqElGcTykN5U4zoPqBfXTW54JJzlcrWULIV5z38Qm+Pxhv07KHOSUl4r
	FGaqXXPAntLy+iB945AomuY0jsZUmpGB0jp6rj6Mt7yDr3qNII46WGbtVvvJFGHpF+fbNwFNIhp
	hDMzfKDfTJYKTyUY453elakph5uiEKYU+g2bX0LMAqSVezrbUinK55yyXxuki3171fTs/o+JHZq
	rcv5A+x0sINCJRMzmMO+QLjUox4gQLjygmNNmOBazfePkMKYrAsvKmmUQoABZGSuCoc085TZbV6
	Pd6g0v916TXMAY+cF0x/iU//2V4oP36JoINPK4xAb/6a+PJ/sqUgy2mORA/J7jXc8Nj0sGq/y3B
	1
X-Received: by 2002:aca:5406:: with SMTP id i6mr4642436oib.344.1546728899550;
        Sat, 05 Jan 2019 14:54:59 -0800 (PST)
X-Received: by 2002:aca:5406:: with SMTP id i6mr4642421oib.344.1546728898835;
        Sat, 05 Jan 2019 14:54:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546728898; cv=none;
        d=google.com; s=arc-20160816;
        b=Sc4hRbBivms3iiQH7boiHTK+RgUYcYH96HsggUfasM0F0eCRCDfozBAnXB/f2OC4P0
         86Y0nKOcsQ1j9/oJStknkFyYk37eBQeJwaKl0Zs5KzsH3ckgYQbTHnX0JIX6oZxTz0to
         LFyAH9be/sXCoShfL13y/jHScbM6Rj8mxH43OpUcQZW+kvPu0yG5iykkrJ2A3fqyXv/s
         PDVYqmTDqRiwMK8dDbKY8KG4Gqa8EdbSdpngwZWwKMseUxayqKOmAtYrNs8FC5jRGLwq
         4Zg/8saUXtAVKYaic6JV6M/mqdvuuvxXYu7wr6K/YsEEUN/g0sWBIOXZsa//oWu3ljV/
         0teg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AWttGSuK6p3ZjKI0uWuqGI1eUFhgSNn7XCSj6cGkh3c=;
        b=AF6KS7z8jZBXT7BvoLFn4l115TVeHXHd0CYn0ICfCvve9APbrIkTJS3gkQkurP0T1S
         T2O9odWlERJ/4x3+a17PBA6KuhA9fp98ZOVfF3cDkGgf8jFZWJs/v9fU8kmMrpsaWyq4
         J7oIE9z8l3xoS7e0FiLSOcsN4K64gMji4NlE9xE5tfIpshCoU+7r3D0yWAKdQUGhoTq6
         MpuQwGgnR94lFk1HRA4T7IhrF9tf/s8mRpDJvCPvaQs0rZYmqbyc9tmqrofZ+lM9Tf29
         rYJJS8WO/Pk9OI+j09c/wwUjJi2W1F7k9QKlBivQffv6EwPnmVN9TVNRN6wd4V0Xzqvh
         pHkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eqx40GO4;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k203sor26180708oib.16.2019.01.05.14.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 14:54:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eqx40GO4;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AWttGSuK6p3ZjKI0uWuqGI1eUFhgSNn7XCSj6cGkh3c=;
        b=eqx40GO4zIHPgE+QjMGQalPzUUHZbK7ytCQV+2CmGTqAUsFauvbP9beoaPzxmfh4d+
         QU4cVFLFYhOt/plmBGqWDbEMqcof5mtji5luIYrMfZuR87Vmn9mcGAGLmARrd8WY8w5J
         wsnO2lspdw7kaXOjpkWdVqh3lt8wOKbujTIYogecUOZqLuhilFfHIEtaxiJuqjlwpjx7
         ITEVR+0BTJp+xdMwflGSwgGQPgU3Y3a4HfKHs6hF2QJFwys4JpD4J/WJNo9vfADUtat6
         7zW/F1xVn3DSNj8gWosEo4KlI2TRjW5aDrfDQidAT+Td6IYrQsMl4UGKPh6jF0qkafFu
         r+NQ==
X-Google-Smtp-Source: ALg8bN45fc2VvmbJfiQx1YNlOX4oneiJm8hW7M1GM74nSdXA6z2wJWuqs1L0ynaCy3lW11h4eN4mTWsIhK100VDBlvo=
X-Received: by 2002:aca:bcc6:: with SMTP id m189mr4630820oif.337.1546728898294;
 Sat, 05 Jan 2019 14:54:58 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
From: Jann Horn <jannh@google.com>
Date: Sat, 5 Jan 2019 23:54:32 +0100
Message-ID:
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105225432.9KHux_3mbW93fpZqsZmeYev4i2mxr280XaC5YAvJgWk@z>

On Sat, Jan 5, 2019 at 6:27 PM Jiri Kosina <jikos@kernel.org> wrote:
> There are possibilities [1] how mincore() could be used as a converyor of
> a sidechannel information about pagecache metadata.
>
> Provide vm.mincore_privileged sysctl, which makes it possible to mincore()
> start returning -EPERM in case it's invoked by a process lacking
> CAP_SYS_ADMIN.
>
> The default behavior stays "mincore() can be used by anybody" in order to
> be conservative with respect to userspace behavior.
>
> [1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/

Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
handler) is less problematic because it only returns data about the
state of page tables, and doesn't query the address_space? In other
words, it permits monitoring evictions, but non-intrusively detecting
that something has been loaded into memory by another process is
harder?

