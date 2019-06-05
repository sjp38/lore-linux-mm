Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B131C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:26:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA7BE2075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:26:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PlkGjGUX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA7BE2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5826B0266; Wed,  5 Jun 2019 14:26:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076D16B0269; Wed,  5 Jun 2019 14:26:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF63E6B026A; Wed,  5 Jun 2019 14:26:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3A9D6B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 14:26:16 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id g142so2513389ita.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 11:26:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CuKsTBPsIQTq7kaBkBZ4doP5Ts93RaiB5cwtxxnYeKo=;
        b=N7pAHn1knWEJXQ0Z9NDa/eEkWM/DfUg+BpqYS/8+/ybJeQPGisiBrNahDuJagsMr3z
         AyUXdz9GZjVEr4F+KZ8hg1LcJdqDytntRV1oZMLv0senQvEgjyuD+4ROTNbMdzDA5JIM
         w5JFKoFhDKhM5qYKYtF5KWmByotfcOD+qf5ONZkYYKuGLgEN4sdJqol4lJZ5SgZVAqzs
         X8NXb304IdOGpKbcSWIgarg8y6IYJr5x9uD4m+SUFhWN0un4Vc1CegjMUY0Fpn6hWrxt
         q7+I/8bG1FRlxSJtOa2TJIgrb2/awCRESDOtbfDnH5eYUn6kK4L9SoqTB+JKYZeMesdi
         6L3g==
X-Gm-Message-State: APjAAAW2CqhbhHLQo9M57NUmgma9jXbVKyUnrQRX5oYTA22Eado9cz50
	MkpZZnZoPuwGruGYqjQW8D7SbWam/wr/HiquT5LHcQ4a2Khm+vibeWr/Km6n7Whk4qQSiwK3GWc
	ib5lYjzz0Ed+UXr8nkXiVF4/3J8fAXvnUhU4W5wEL7fgX6ags1UyqylDul4Rh7fesXQ==
X-Received: by 2002:a24:ee47:: with SMTP id b68mr827446iti.36.1559759176595;
        Wed, 05 Jun 2019 11:26:16 -0700 (PDT)
X-Received: by 2002:a24:ee47:: with SMTP id b68mr827410iti.36.1559759175876;
        Wed, 05 Jun 2019 11:26:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559759175; cv=none;
        d=google.com; s=arc-20160816;
        b=tNQbaxCZWQNpm4783BJgPQVBCECpbtveoscc2TS+8ZoA0CET0Ow6mOoGO6L8gDhlae
         IMhyScBcwVfbjNUk6QTSvxObfsbu/5+BRRdqeQtcJ0QtWdoEiAd4we7bKdJY/jUDA6+x
         LWIvYRYZK/IFyIn23rFa/o8oVdzDDoyVTv/CM76R0gHFw9IGEtG9wJrub9w102G8uHR2
         d7vC+jOFLcTNwb8LzauINNIdFO15F27vAY21Y7SSY9vb/QvVz4U9H3oOTBnwvYgf/jVz
         UH3cZUVnpHgaLmr+orPVpmaDaxXr2DmPd8sU8rqYNqT24ZhdMbCh35KXNonB8wOCqtEN
         Jxqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CuKsTBPsIQTq7kaBkBZ4doP5Ts93RaiB5cwtxxnYeKo=;
        b=CwpleRbsXDJ650w5ZvelRuvQK1zGbQn+BbHxGj6z5+umF2ZypCRHQs7Xx/iXxL1GBo
         OLGzD0zR/WAf1d1AQSqugrahlgnT56y6YUUwjqIDbQAX0XiNgKn/iPogSQuiVdP+8Vn1
         QJBdL1dAD1gZ50TJphYobO/6MC1+pmKGYgwXRJmk5K4lwdlIBXd8jk4IGKKEiojIzSth
         KMlsgpJVBFl6O3S+WoaGXsFHqKLLnDLOlvbKzxUM0xAEJy3kg48xE5r2kIrjDNPvHuiK
         s/6nbHeHEISkgaEz+HUZZVcRGJ/npg8CvFIqVmbuZBryDB0vKnCW70HUvfMEvnB9g7zG
         ThUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PlkGjGUX;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185sor11633229itu.16.2019.06.05.11.26.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 11:26:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PlkGjGUX;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CuKsTBPsIQTq7kaBkBZ4doP5Ts93RaiB5cwtxxnYeKo=;
        b=PlkGjGUXwzj17TBdlmfkM3QAvf/E4BNtOY6z86bVQd4magMo+EcHQNSjIFIMHSv9ep
         Hvn0TJUbPu1jT6y+TjRG17nCAMo2zeTFBjnwLXvyDDHdIs/phhSJ5FGcELiuZ3qi4qb4
         8r2u0QNafuNOyyE9n3i5EJIFPbKUN09gquhoJ1Jq5l847nWhl3wXZXG+e0tX2A09B2Ea
         t4L1U4es8Xu93CiBgt7golQhzRx1HiABCzolmi+9lkEYx/cOhkMz8PX2Q17JQViNF8KR
         kPmbzLqAvRGc8MlXh9si9eN7nJ94ifGV8+0AQezoJE43EQfRV4SMR1Ea1rT4lxoRcBoK
         um3g==
X-Google-Smtp-Source: APXvYqzg2Q8FD5mu9akBujndKp639v+Wwjk+fWqAAHLrXjNUx9Ab4kGUMVzGf0NiOxZjZs7NT3ykGTBqnEr/028Fy/w=
X-Received: by 2002:a24:bd4:: with SMTP id 203mr26657993itd.119.1559759174805;
 Wed, 05 Jun 2019 11:26:14 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190429193631.119828-1-matthewgarrett@google.com>
In-Reply-To: <20190429193631.119828-1-matthewgarrett@google.com>
From: Matthew Garrett <mjg59@google.com>
Date: Wed, 5 Jun 2019 11:26:03 -0700
Message-ID: <CACdnJuvJcJ4Rkp7gBTwZ_r_9wKtu34Yko+E3yo07cwc53QrGGA@mail.gmail.com>
Subject: Re: [PATCH V4] mm: Allow userland to request that the kernel clear
 memory on release
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 12:36 PM Matthew Garrett
<matthewgarrett@google.com> wrote:

(snip)

Any further feedback on this? Does it seem conceptually useful?

