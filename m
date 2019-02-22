Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5126FC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:48:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 036242070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:48:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="mVLBaJmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 036242070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24768E013B; Fri, 22 Feb 2019 16:48:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A133E8E013D; Fri, 22 Feb 2019 16:48:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DAA68E013B; Fri, 22 Feb 2019 16:48:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62AF98E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 16:48:46 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id i3so3307279qtc.7
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:48:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=P/Qah4SoF/ARa10cixXMsYgG3Q8m0vAUyaMuOpWsnV8=;
        b=C4GZaqDys8HFtm3iKfIkiA8enFEt4hxVnlpxQU7phH8P67XH25BdBjjmQ2TVC+nMbp
         VIZv2LI/KgIc81EsyBsbzCdCVuq3L7Hjw056IDje7XSoDXLhAnwz3LOlmS9ClSKrLfDG
         qzgh5NWoZF3XtvbRwwGoKeNvcnwwgshnsDfkOh1AsZjaupaZinnT6yrg11sJ1LG3j0EN
         4ff5/yW8bvWFeRh4HiaUYcKZCeO9hp0otemPicxTG091MuZ85ovaQYSo7Yy9Bt8kn3Cl
         YUAVDNWeCwWdiJ2oq0Rbd8AyLr0G9n1D2xg7hTw0NZ0NrTPTu+kASp5+Th0CymbK2MI2
         y/hQ==
X-Gm-Message-State: AHQUAuZ3fMFNvf2I68qxLQg6QJeDN35GPMM/lHsH8agi2xUKLOtS6eIJ
	lwgXTXBHTemP7XDhPNVjv303vrsHJP+1jHEpFGiuGvwhPxbhk+KVvr4RAxl6DizZsTbKTesNDrJ
	j4GtB5hXjwXB7OLpoA5vk5OptTMzruJAEtUE/3MDFd60wm7wrH4wXvtC0YJYkgV/hOjLRdeKzOV
	EMFSMeIjz6r6iyAzvdWtKLfQPZNyd/hNXwW47beJrQwppXcg8Rvr5VNAeSLw3aUDpgVMzI+yTyq
	bdQuiwNX/Z0LC8dCNtyim1dym+cS5OKVNDBdBq23wugAgW6Sg9h88GAGdicY+2LxvJ9IQ681fa2
	CTPKmqQpMuqgJUFv2733JsEiBhZR/EQ1S0wsdZf6yRt6JoB/Usa7nbBXZqpFCDZ9YWPYg+eCf14
	o
X-Received: by 2002:a37:2fc1:: with SMTP id v184mr4627883qkh.71.1550872126125;
        Fri, 22 Feb 2019 13:48:46 -0800 (PST)
X-Received: by 2002:a37:2fc1:: with SMTP id v184mr4627861qkh.71.1550872125581;
        Fri, 22 Feb 2019 13:48:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550872125; cv=none;
        d=google.com; s=arc-20160816;
        b=sj7FxtQT38IIJCg9M2gR7GYFBcc6rw/tuvKB6IgzPaep+Go/3jf3HZoil2xzrSuUhe
         xhMRTsOx5CY82Psg/2LLJeHFhaBkSDbxSfBp6G9C5ReBOhNZ4fp2WjOm3DJMRuVzseuu
         0MMNf+5azAGyJst5Wm+PSsNIvcsbwrzcFE8DwpWrJlxTkgAcxhxw1HH3ccpKOt3KA6gJ
         V2Ff66hdpwuhiaIzQ5ymB3oQLzexEM36NcWQdaPUDmcqziVz0dEuVWS3NeiKQ8XIUpyj
         6ZMnLXyfu7k+t6SMAQBpYANIApU4GnetkRMemGPbyf4eo4Y674yFb2Ij9eHBdQsXYLcj
         wKrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=P/Qah4SoF/ARa10cixXMsYgG3Q8m0vAUyaMuOpWsnV8=;
        b=c66eJi6HL7ENbyjw5M1R9n5Dl94iQnOmAQCpht3cW2J6LryXeC41eexWBD0NbijYWm
         whh2IxuHCLkqAlIsEqQ+y+3gL4B027zQbjcJ24cnKO5HKP0xJfapI/ggCJ+diFjz2h1i
         NPI3DxlQijBMmJkoiRwJZOl1aaU+f18KVv7UUKLjR7DQA7SbvZLzP2Js6Ww/C57+bIrY
         pxEhDF/dVZS86rZG7ibLnB8EXNlXYZSVsd3EO2wtsnNVPQWZvKEmnRRJ1VJ6LO01/5FZ
         rAiyw7VvGVflXvsHcIYPVROVh3HL9XxI6VrVlpdE1BEdhG0L0AUDkgLydMnHDPidUQXF
         yRsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mVLBaJmz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h10sor3440137qte.61.2019.02.22.13.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 13:48:45 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=mVLBaJmz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=P/Qah4SoF/ARa10cixXMsYgG3Q8m0vAUyaMuOpWsnV8=;
        b=mVLBaJmzjOzLHNR4iJUXNO3zjDkDAssnOlVhM+z2z+eFHPvD/bwQ3gyuvAThe9rVjy
         /58/jK9LIQ/MGjCrFzQcocrnAMVFeNMeWqr6xubr4BCkri6iP/M6uHm1pEPWXOj84iaR
         uffPglp5+kCET/dWAWKOGUIDuk8QFkU4zNgopPdSOTm9ELet5seVEQo/IIADOqpnM8ez
         pAOnn7xoOGfKNK0QCs7/RUmdnXGxti/pGTlRitRWw0JjMTdHOmDI+p6CSfjVYjQbiy89
         ZbsrR8Nc0BJYyMHFlujSKTj+re7lW+akQNKv0D4vHkZhR50jYbLBLuzs/0rqUW6e0rrj
         5GXw==
X-Google-Smtp-Source: AHgI3IbzX5gI8xQg0E2gn3JkPDEuyy0SwwFPLXLzLTKXZ9+6P/qRG9o3C6PHPq58MZEGTOpPcc2k8w==
X-Received: by 2002:ac8:604:: with SMTP id d4mr4836608qth.71.1550872125353;
        Fri, 22 Feb 2019 13:48:45 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id r24sm1563642qte.60.2019.02.22.13.48.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:48:44 -0800 (PST)
Subject: Re: io_submit with slab free object overwritten
To: Eric Sandeen <sandeen@sandeen.net>, hch@lst.de
Cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>, jthumshirn@suse.de,
 linux-fsdevel@vger.kernel.org, Christoph Lameter <cl@linux.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
 <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
 <0a28db73-7e52-9879-276c-adc6aaf05d4d@sandeen.net>
From: Qian Cai <cai@lca.pw>
Message-ID: <e2fdd737-2a48-ecea-10b8-f90d6866df34@lca.pw>
Date: Fri, 22 Feb 2019 16:48:42 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <0a28db73-7e52-9879-276c-adc6aaf05d4d@sandeen.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.212012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/22/19 4:42 PM, Eric Sandeen wrote:
> On 2/22/19 3:07 PM, Qian Cai wrote:
>> Reverted the commit 75374d062756 ("fs: add an iopoll method to struct
>> file_operations") fixed the problem. Christoph mentioned that the field can be
>> calculated by the offset (40 bytes).
> 
> I'm a little confused, you can't revert just that patch, right, because others
> in the iopoll series depend on it.  Is the above commit really the culprit, or do
> you mean you backed out the whole series?

No, I can revert that single commit on the top of linux-next (next-20190222)
just fine.

