Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26DACC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E448B20869
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:29:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E448B20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E308E0002; Tue, 29 Jan 2019 05:29:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BEBF8E0001; Tue, 29 Jan 2019 05:29:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 489758E0002; Tue, 29 Jan 2019 05:29:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 049058E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:29:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so16468928pfi.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:29:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=umrS+ZyRHatmUJD188ntGaiZ2jPJqpgQAXJ8bPgP9gI=;
        b=NGBLp2bsbWgAs7dFGUxxUksakdaAJN9AHjybizb+9qtpvXyhNcrW2JOF3jJldwYUgY
         96DwY0pK82a/oeOGpn+u4/gNd7EzL5JihhjRurAGjPkKGJHkc8kyYn8bAWSqy5wHa8q5
         i99mbnEU+51OeCWWzPuCXMQ+gvSegInCzImnPwNK1lO8TrYH0nchsrNP7dgTiRBuuUbT
         E5UOCgiYBRR/5vcbC/tiDjzG9LIuNycnmClNsueQgJ6tA8CVlo6YRLlIAhCj5E9Dxt4j
         0WRNOrC1Ch3riU10wo4v/q4d0Ad48ZgUno6iNyVInHoVWWexBEeNsUDzdTcuSVSkAmbW
         KQVg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukeAhKJ2bLfuI0NZd1vY9XpbDesk5LWTUkNQvQXG8lbdFA4Glk6S
	x8rpi858JHENdt7VoQLf55iT2+jjySBOdNqkzaRgE/fIaJa82RuFQUe3oh5E90aq8bLuhdpVPIW
	AMzjNHuo9PsUo8CV38+OqYeD1HjbF+tKYdr8uuEQYfr8NZ1W/M/U1gYa1o1aCQe4=
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr25710073ply.65.1548757769665;
        Tue, 29 Jan 2019 02:29:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60kzYe8pSl1FtOU3zDFvm7txd9PIkrAgUutWLL7lBZoUyOqnlSo5vTXOMa8RFr5RYLm0do
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr25710034ply.65.1548757769008;
        Tue, 29 Jan 2019 02:29:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548757768; cv=none;
        d=google.com; s=arc-20160816;
        b=jLiQ5R/HhwmgUUWsgvQnOMUqzIT3wfrWiSSpUAbwHrogkK5gCLIw+kgp31xTKPbz1X
         /kDfexzmZTvnyMQLNX0oYUeiXhAKlk8mAHoQh1HtyiJtOTBEX72m3nK9wSk7tkiTXIlJ
         alClBlhDyU1Hpi7bsK1Ell0SZBvt31PEP6l6czVd8ut6Z9HYW9f0D9yb8SHVKcPnvIVW
         z5zAIqmSbzAdbW3dNyl24jaqKLQvRWIobcZwCwsv1tLDgGV9gYhbWiY9Hc3Br9lt6afe
         DWeq+KXp/vrUo0FiXvAvia/v8uVtREUdot7KCZGqAYmGCeIO7AK0ZgJpi698179BzQLo
         n6yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=umrS+ZyRHatmUJD188ntGaiZ2jPJqpgQAXJ8bPgP9gI=;
        b=LFA931pRa8+/pyb+FR8MYm+DmTuw+W36OeyeUj/ErnenvbuPEFeVXjsrsYtK1gZwR7
         A2Rv5L4D1G6I7k4TTYyqEICIUWgOOxifx76jehtoohHNg7zDnqAWo3fqBDyY+0muVF6M
         8BBbDGdoTt9yT46nu5tzaw7Ese+kcklC7IU76CydlLkBEcIQirfvuccsRqYWRfiZDkBC
         OiZBBg2oKgYp3xeZVcCg1vYZAPTeCSK5Y1bD+6rQFGa2prVmOUATTlph9SpjH2hlotNG
         /sjlXTcdcqYJoZqJSikG2mS9E2NTurcqHzsdBTg272wrixjgR9F+yzRwMccBBhC2N9Js
         jipw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p64si35615947pfg.79.2019.01.29.02.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 02:29:28 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43pjR63G0Gz9sNG;
	Tue, 29 Jan 2019 21:29:22 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas
 <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S.
 Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert
 Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao
 <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner
 <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek
 <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek
 <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger
 <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King
 <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck
 <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org,
 kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org,
 linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport
 <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 09/21] memblock: drop memblock_alloc_base()
In-Reply-To: <1548057848-15136-10-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-10-git-send-email-rppt@linux.ibm.com>
Date: Tue, 29 Jan 2019 21:29:19 +1100
Message-ID: <87sgxbrc3k.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:

> The memblock_alloc_base() function tries to allocate a memory up to the
> limit specified by its max_addr parameter and panics if the allocation
> fails. Replace its usage with memblock_phys_alloc_range() and make the
> callers check the return value and panic in case of error.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/powerpc/kernel/rtas.c      |  6 +++++-
>  arch/powerpc/mm/hash_utils_64.c |  8 ++++++--
>  arch/s390/kernel/smp.c          |  6 +++++-
>  drivers/macintosh/smu.c         |  2 +-
>  include/linux/memblock.h        |  2 --
>  mm/memblock.c                   | 14 --------------
>  6 files changed, 17 insertions(+), 21 deletions(-)

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

