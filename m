Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE00AC43444
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A552320868
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 11:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A552320868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BD2A8E0003; Thu, 17 Jan 2019 06:41:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46C8F8E0002; Thu, 17 Jan 2019 06:41:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35CA98E0003; Thu, 17 Jan 2019 06:41:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06F3C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:41:33 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id g76so3228181oib.19
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:41:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=xN4v/rkGke6+i/Qav13HjBnLjQRjemEO+ltzcFe4AUo=;
        b=YdAC8zOy3LPDpYYTzc6pawyq0AcV6/FvLCaxJD+gWp/gcXqNZoIaFu44myM/o1BBC/
         kwlsXAm83S2+k0O7TosPrDSTn4wuz/C3W5wJhHhrTuqmQbVn2A+YJSC4JC+o3EzeHiyM
         MglS7e1qhcFtV6q0f1fdCQc5BJoiJvYVcE6wVmnLjwAivI+BvebwnqLEKf2zAu7nkkcN
         J6G1OrVliSLLHJDn+wo56YrzMlNNk2jkNOTQeFzhd4aAycQvOH618cKylUdl8TmOpzWV
         G3saQg5+h7I/k0cP7QgSN1C1raE/B3CWOO1WsD66qnw2pDhVZWAHYfIte362g9cxHnk+
         j/bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukeUvkp2T63yk7d7GApo88kMKcIgA1MZ80d+lh4NPDoIFJ18tQCZ
	DBOwDJwRDiJWXI9dJvfHSKm9JIxrpUzIFbojbqppk4V+xosOa2+GufAj2OeCT1yFzhOL5PyTJq3
	MZ//b+S3N5lp2Uk9gMpd2/m0uRabUwMnt0TtfwmHYHylaHc9yCLUgifFckNSFbsKwzTkrOnb/dC
	PFhBCiDKL+AYLlj0sQ45DbMBOLoTDPhb+pdXKcbAnMkU5bn/2jwiIMATIrnxTAj6UdhQnPMNxx9
	80O6GVjAX+J1i/6ChtJCHIDV14qwyM04xCiV6xeyMNWHMqErwVLIuM7J4J+WQNGvTWboH43SLCZ
	6rKEk01/SpV8g50FWIsTu/PphSjN8iqjjxKSlSnQt7LBHikcjOo9sOberwXrTE/qiCa0OO3SeA=
	=
X-Received: by 2002:aca:5344:: with SMTP id h65mr630520oib.13.1547725292702;
        Thu, 17 Jan 2019 03:41:32 -0800 (PST)
X-Received: by 2002:aca:5344:: with SMTP id h65mr630459oib.13.1547725291164;
        Thu, 17 Jan 2019 03:41:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547725291; cv=none;
        d=google.com; s=arc-20160816;
        b=W9Cp7ZIrVAAWUAV2jxeWtBmv7F/Qh540kybZ9d8n4bpXRI/6sLqTXq7asEAHP2JPxB
         RdAHHYaTc1Nd70FZckljUqh70/EfIehVYWPLQbsA5m9E35Te+Z0Q3qq96dwhFNvXkWIM
         OaNmVSTCtYUqS84fLMiisxRwTylerObVyuCW5rh/IkbEwsTR2g4rwZ22sggJJV4FJRWR
         EbwsJkl4TlYjVBbWVWtrzi72bhKTpcYxq1Ipgo9mLmmouwVncHAABmUvmzmjSQNKOixG
         OS0n8R/6G6eySh9n0I5cNt9lzuPojr1jLp/Wlg94o09isv5L2MJ6RKGmzX5haePtP3k3
         q7lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=xN4v/rkGke6+i/Qav13HjBnLjQRjemEO+ltzcFe4AUo=;
        b=NX/lHzhbGXojDk7Q5hRj9jOE+FzS1FmTkwIEMLMM/QhGVIzUhyTEO6q4zYGYyn179U
         nqnufAPz/pzwu/M6/YJhow0XDkTNzHDAdTOquK1HnIgNbYZDEsorOuDIgDDXpUlS0z8D
         VJ23V2GNwg3UtrTkGKnUD521Vct4/5mlvgwnlcjDB1afYVku07fp1nudJsDf5bSfa0Pc
         RZ/iXbLpkxHkGICFG2VCDjlHGvrOY0oJZ/UH+2vNDK7cRYrv2cZccYsgH8+PW9na0UmO
         9DosE5bMp6tX+dU8LIi2hUxxIE0t75DJGPKTLbcxJh1ByqReBX9yGFyZzFCgw7FhSMSX
         JGJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u16sor639452oiv.13.2019.01.17.03.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:41:31 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN4UQ/rpbV5cQBNhkg5p54E3HSCP5F7ElF7yDnIxmZsPlC6FJ4Q4g1QsWewezmj4aYuAijHbgKpTACnKXjBAfL4=
X-Received: by 2002:aca:b642:: with SMTP id g63mr5392264oif.195.1547725290609;
 Thu, 17 Jan 2019 03:41:30 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-6-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 12:41:19 +0100
Message-ID:
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117114119.fDBKZ1TrmbUdWpULu_IeQewvE1DiyAvXVjkpun1Uir8@z>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Add entries for memory initiator and target node class attributes.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

I would recommend combining this with the previous patch, as the way
it is now I need to look at two patches at the time. :-)

> ---
>  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
>  1 file changed, 24 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..a9c47b4b0eee 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:                December 2009
>  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>                 The node's huge page size control/query attributes.
> -               See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +               See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:          /sys/devices/system/node/nodeX/classY/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node's relationship to other nodes for access class "Y".
> +
> +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node list of memory initiators that have class "Y" access
> +               to this node's memory. CPUs and other memory initiators in
> +               nodes not in the list accessing this node's memory may have
> +               different performance.

This does not follow the general "one value per file" rule of sysfs (I
know that there are other sysfs files with more than one value in
them, but it is better to follow this rule as long as that makes
sense).

> +
> +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node list of memory targets that this initiator node has
> +               class "Y" access. Memory accesses from this node to nodes not
> +               in this list may have differet performance.
> --

Same here.

And if you follow the recommendation given in the previous message
(add "initiators" and "targets" subdirs under "classX"), you won't
even need the two files above.

And, of course, the symlinks part needs to be documented as well.  I
guess you can follow the
Documentation/ABI/testing/sysfs-devices-power_resources_D0 with that.

