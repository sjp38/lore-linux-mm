Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA902C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:17:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78C4720578
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:17:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="ogISHwwq";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="ogISHwwq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78C4720578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0548B6B0007; Mon, 29 Apr 2019 08:17:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003D16B0008; Mon, 29 Apr 2019 08:17:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E34CB6B000A; Mon, 29 Apr 2019 08:17:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE5F86B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 08:17:24 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id o17so8426529ywd.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 05:17:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EPvrtOPXbSqmMamLp7U6TjQ+DF8mn7HYnWgo0usVeV8=;
        b=ppOurOxoRFmAh3RfI45PU22PPpu0lxrW/Z0khrm4y3tDaXKS1E1w+8LEsRx/3FlDQj
         gbNJ01wvCR14TBoZjwoYxBGYJlTL2jPAyKsJxx0Ys/pf4dHTbhAJislWskVGf0M+YD58
         7k/VoOXzyDj9MU2NlZAXcqUUSm+T3kXqQcBk+BdhJD4E35+xNATVJT0deiwtChNBFOS1
         dBAkhhLnZs2pplEjCaYCNtpnxyeCXxKGSLsL340A1xkdrMpFn/YJW/tCqswVS8f3w8FV
         ZcGF4PUOFbyAhRyiEzGIfLBJTxuLYgE5xe7xLym0ZB/hlFZKEcqPQnW8r0AymENqzrVy
         lP7A==
X-Gm-Message-State: APjAAAWjYEVB/5pcJu7hUWcg+55zpQYJV6IHl4yIdN8BYnsjQXknY+r6
	z6UxV+NoJqHfVKpKvSI+BNzEkIRRABLzWGqtDVK+4jRGCnk1l7z22SSoi4mDtT9pjDyvn/UC25Y
	hu4YmROEij+6Ym6PGmT/z8MowfGDgTnMlQvbCrVk1im4vw1O4wcac/dd2yLTXKb/KMw==
X-Received: by 2002:a81:1390:: with SMTP id 138mr49211580ywt.230.1556540244345;
        Mon, 29 Apr 2019 05:17:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5VqQeY2e07ShM5FYKpYuUZFjBLBRdYL71FOSNruttG5jq4AhQ7qpXL1t+xY8jLANgLqd8
X-Received: by 2002:a81:1390:: with SMTP id 138mr49211533ywt.230.1556540243725;
        Mon, 29 Apr 2019 05:17:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556540243; cv=none;
        d=google.com; s=arc-20160816;
        b=wmkKW0RXiUPIqWguPnnezB9jQb4/5sM2zMZ4ceCGE8ATMPhFv9i5QHekL7ORFlFs9M
         +9wleL+hcqYj2tzJg11+L0pnfGJ8AJIA9te+NMIA28+zbYMXOBdLDSdJxV899E5wJdVu
         TOJ0ZExBbKsbhviyD0885RRfOSmF6XudZTp7MmQReOMrW8gr53JgElkDYi6GvsrClpfv
         Vp6KVO/fApIFRu0C8fH5e07bVNkWH2FBH9bCB9VY/6nzPsnzAXDfbOkk5L8ZLthQazT4
         LbmQyeWew1Wrzc/pw8GNHuOKuA86gXEkYOjNt6tZo4lNihj0z3q3P1ZNKdK02gWov6dK
         fyFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=EPvrtOPXbSqmMamLp7U6TjQ+DF8mn7HYnWgo0usVeV8=;
        b=q71lowGcHOsXq7oNbpnCRBO/DYoJKfZa3TkVBB4yHRtBmGt/omZyVBLsk32A3EArhH
         4iQHent4/nr/pSRB36kPnmm0fs6tEUWxMYGP4zc6lPjmJ6mnEXnDrTlMiIAYWv8YlKoo
         ep9SnrGOiDZM4Q5MoktN1vu9T9Z96zxFiBrsrKYY5bJW/uFkguzPbAkd5Rq8NDyYZf0q
         uiOY7G62Tl9PboIjkU1pI2XU7EK+dn9u01dsJObPtLHIIe6AToSgQ0Idr7YvIuKKywoM
         6+2zIT6L4KUyWSHRzmGPiGtQrToRpC9m5QOLj2f3XKe0d5P6oT54dmOadTfLYPsBmYEs
         R3kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ogISHwwq;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ogISHwwq;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id 142si11150372ybn.404.2019.04.29.05.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 05:17:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ogISHwwq;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ogISHwwq;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 5EBF28EE1D8;
	Mon, 29 Apr 2019 05:17:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556540242;
	bh=V8W4i17PSPDCdFQgaQ9datYSRuZ6HJF8DVD1l4ouvDk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=ogISHwwqWQR46xjt+1BXFuVlmD/ievw37QJxSJbIs+glnx90FnZ+stHg6eYqOk1Xb
	 rctKlGG5rAmGXfePLpiFcA27yJVAbeN8WjUk0pFm101/zHrbYEZ66fEW7yidn5un9H
	 TclnOUVVeIjNrhPBHgoz44MCM1/Pyu/9mzlGebfc=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eMNwNV-9nJIS; Mon, 29 Apr 2019 05:17:22 -0700 (PDT)
Received: from [192.168.100.227] (unknown [24.246.103.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 534438EE03B;
	Mon, 29 Apr 2019 05:17:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556540242;
	bh=V8W4i17PSPDCdFQgaQ9datYSRuZ6HJF8DVD1l4ouvDk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=ogISHwwqWQR46xjt+1BXFuVlmD/ievw37QJxSJbIs+glnx90FnZ+stHg6eYqOk1Xb
	 rctKlGG5rAmGXfePLpiFcA27yJVAbeN8WjUk0pFm101/zHrbYEZ66fEW7yidn5un9H
	 TclnOUVVeIjNrhPBHgoz44MCM1/Pyu/9mzlGebfc=
Message-ID: <1556540228.3119.10.camel@HansenPartnership.com>
Subject: Re: [Lsf] [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller
 ?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, 
 linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org,
 linux-mm@kvack.org,  Jerome Glisse <jglisse@redhat.com>,
 linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, 
 Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 29 Apr 2019 08:17:08 -0400
In-Reply-To: <yq1zho911sg.fsf@oracle.com>
References: <20190425200012.GA6391@redhat.com>
	 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
	 <503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz> <yq1v9yx2inc.fsf@oracle.com>
	 <1556537518.3119.6.camel@HansenPartnership.com>
	 <yq1zho911sg.fsf@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-04-29 at 07:36 -0400, Martin K. Petersen wrote:
> James,
> 
> > Next year, simply expand the blurb to "sponsors, partners and
> > attendees" to make it more clear ... or better yet separate them so
> > people can opt out of partner spam and still be on the attendee
> > list.
> 
> We already made a note that we need an "opt-in to be on the attendee
> list" as part of the registration process next year. That's how other
> conferences go about it...

But for this year, I'd just assume the "event partners" checkbox covers
publication of attendee data to attendees, because if you assume the
opposite, since you've asked no additional permission of your speakers
either, that would make publishing the agenda a GDPR violation.

James

