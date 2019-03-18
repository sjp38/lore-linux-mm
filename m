Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 107A7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 08:42:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B951214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 08:42:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B951214D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D90066B0003; Mon, 18 Mar 2019 04:42:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D18866B0006; Mon, 18 Mar 2019 04:42:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B92646B0007; Mon, 18 Mar 2019 04:42:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F54C6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 04:42:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so1332493edd.9
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 01:42:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SU9pRSc/bc5v7Ui+W+UMiQpLuPyDCUa3DLTWyr5Yquo=;
        b=XVDKzY0o+fmKzMIXPmBxGRepivc/3VoGNIz+GzgSYExrzqPqNY5RUBDumvBhnbgO7O
         YezHA3Puc7DZtt1GKtJRo9KEE2PdmKSKn6mSyJNUZAr8R6kIa3PT/O+piSwFsTHKxq1Z
         83s6M7hRZXw0LCCj228/GKy2xuE/ONl/jJqaG+Qaz/afJmIYppRPyNrvO+MeaULAl09M
         7OW2xF9bqIfP+1DFNfeATrL1iS0c7LDS/QzTKqsZKmiKuXdQbbBIf0afJHzr7UOnXVQs
         CFDRbWUO25CCTt8aJgJ9b6beEW92cXIsvHd4x6KO/eJzx5FkcagZCIAnAYH56mHCyZvM
         TTRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV21XdxFQ2vKGk4B32YLt6G/1mOPl54+AA77NNDYXNH2zT3xr3C
	5GC9nZs/k/uEwPj5f93boFHYGJbE85C40EOWmMkv0yNdGik7lVUGeEERDJHvnp7LeUe34mJcZWm
	sHSb4oUzUD40WKDrBDF5uDO5WbyEvazAD0qD/00SzF1ze0QjiZPZ+T/autjhtwuBDlw==
X-Received: by 2002:a50:9863:: with SMTP id h32mr12510645edb.291.1552898573776;
        Mon, 18 Mar 2019 01:42:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPwswBz3hfIQRbwlZujmX1jSVuvo/IomyQwcf2cv08ofHBsRpZP2l3Iks8fyJJE2k9l1dr
X-Received: by 2002:a50:9863:: with SMTP id h32mr12510596edb.291.1552898572567;
        Mon, 18 Mar 2019 01:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552898572; cv=none;
        d=google.com; s=arc-20160816;
        b=YYUl8zc0oLiBuCnYCrAd99qv9xFaNTLyhf/hh2lgv80z2JG9wxJxGnszfQjdRYQ+4y
         UENh/zoHxEN183myNJEygPvsCsQC4vncbMWDjvBJjq7riETxHARioHHWMXuhvmJVk4CI
         7nNJx5nfQ5Hnx7vO3OlyYdIF44Bnu0PxiabXZjOksstPK1c4KmP18lRyyokdKQDAtjOg
         k+xr4/mv012xfcF4QDZ6b5nqyP7roGUbucscuk7lycgvGOfrdiM7Hk9zinj0RMLzKHIf
         Fl5JwZDiImxJAA3O9lW24yeqKSFezRI4j1tIwPnsZpxFHCkqd6TUVo/tpOYNthfynZfR
         KgCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=SU9pRSc/bc5v7Ui+W+UMiQpLuPyDCUa3DLTWyr5Yquo=;
        b=JwBN34DytjO+7oRpjYOnLaoVFFB7l78WQur0BBa7FSU3cFFKfBcwTJmvi2bVE2j/MM
         nyCV8BDxbF6kaKdOmN6WcW+BhLwaiE0eypEvnYVnqeHHYyDejY9uyVCb8E3L/6wgn4+y
         vLcYt2Ryp2Te6gfb0a+wathvue7iehCsG2MhUiun7CSMLu21X150yptY89n15ZTzlbCn
         6rUg14gIGxUlZZuaxtBdeuplEfXWkIkiQEH7BPJmzemJlvMb5V1eKvNZ88AlXwWWxqWb
         Ba1ORx3AeIINdCA6IuMa/IG/SlvmCsq4aK3S4bMhVv5t8fRfX+8XH/vtg0DKCbFrEpuh
         jiFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si2774669eds.268.2019.03.18.01.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 01:42:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 07BF1AD8F;
	Mon, 18 Mar 2019 08:42:51 +0000 (UTC)
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>,
 "aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "minchan@kernel.org" <minchan@kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>,
 "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>
References: <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>
 <SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
Date: Mon, 18 Mar 2019 09:42:50 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: base64
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMy8xNS8xOSAxMToxMSBBTSwgUGFua2FqIFN1cnlhd2Fuc2hpIHdyb3RlOg0KPiANCj4g
WyBjYyBBbmVlc2gga3VtYXIsIEFuc2h1bWFuLCBIaWxsZiwgVmxhc3RpbWlsXQ0KDQpDYW4g
eW91IHNlbmQgYSBwcm9wZXIgcGF0Y2ggd2l0aCBjaGFuZ2Vsb2cgZXhwbGFpbmluZyB0aGUg
Y2hhbmdlPyBJDQpkb24ndCBrbm93IHRoZSBjb250ZXh0IG9mIHRoaXMgdGhyZWFkLg0KDQo+
IEZyb206IFBhbmthaiBTdXJ5YXdhbnNoaQ0KPiBTZW50OiAxNSBNYXJjaCAyMDE5IDExOjM1
OjA1DQo+IFRvOiBLaXJpbGwgVGtoYWk7IE1pY2hhbCBIb2Nrbw0KPiBDYzogbGludXgta2Vy
bmVsQHZnZXIua2VybmVsLm9yZzsgbWluY2hhbkBrZXJuZWwub3JnOyBsaW51eC1tbUBrdmFj
ay5vcmcNCj4gU3ViamVjdDogUmU6IFJlOiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xh
aW0gdW5ldmljdGFibGUgcGFnZXMNCj4gDQo+IA0KPiANCj4gWyBjYyBsaW51eC1tbSBdDQo+
IA0KPiANCj4gRnJvbTogUGFua2FqIFN1cnlhd2Fuc2hpDQo+IFNlbnQ6IDE0IE1hcmNoIDIw
MTkgMTk6MTQ6NDANCj4gVG86IEtpcmlsbCBUa2hhaTsgTWljaGFsIEhvY2tvDQo+IENjOiBs
aW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBtaW5jaGFuQGtlcm5lbC5vcmcNCj4gU3Vi
amVjdDogUmU6IFJlOiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xhaW0gdW5ldmljdGFi
bGUgcGFnZXMNCj4gDQo+IA0KPiANCj4gSGVsbG8gLA0KPiANCj4gUGxlYXNlIGlnbm9yZSB0
aGUgY3VybHkgYnJhY2VzLCB0aGV5IGFyZSBqdXN0IGZvciBkZWJ1Z2dpbmcuDQo+IA0KPiBC
ZWxvdyBpcyB0aGUgdXBkYXRlZCBwYXRjaC4NCj4gDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbW0v
dm1zY2FuLmMgYi9tbS92bXNjYW4uYw0KPiBpbmRleCBiZTU2ZTJlLi4xMmFjMzUzIDEwMDY0
NA0KPiAtLS0gYS9tbS92bXNjYW4uYw0KPiArKysgYi9tbS92bXNjYW4uYw0KPiBAQCAtOTk4
LDcgKzk5OCw3IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlua19wYWdlX2xpc3Qoc3Ry
dWN0IGxpc3RfaGVhZCAqcGFnZV9saXN0LA0KPiAgICAgICAgICAgICAgICAgc2MtPm5yX3Nj
YW5uZWQrKzsNCj4gDQo+ICAgICAgICAgICAgICAgICBpZiAodW5saWtlbHkoIXBhZ2VfZXZp
Y3RhYmxlKHBhZ2UpKSkNCj4gLSAgICAgICAgICAgICAgICAgICAgICAgZ290byBhY3RpdmF0
ZV9sb2NrZWQ7DQo+ICsgICAgICAgICAgICAgICAgICAgICAgZ290byBjdWxsX21sb2NrZWQ7
DQo+IA0KPiAgICAgICAgICAgICAgICAgaWYgKCFzYy0+bWF5X3VubWFwICYmIHBhZ2VfbWFw
cGVkKHBhZ2UpKQ0KPiAgICAgICAgICAgICAgICAgICAgICAgICBnb3RvIGtlZXBfbG9ja2Vk
Ow0KPiBAQCAtMTMzMSw3ICsxMzMxLDEyIEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlu
a19wYWdlX2xpc3Qoc3RydWN0IGxpc3RfaGVhZCAqcGFnZV9saXN0LA0KPiAgICAgICAgICAg
ICAgICAgfSBlbHNlDQo+ICAgICAgICAgICAgICAgICAgICAgICAgIGxpc3RfYWRkKCZwYWdl
LT5scnUsICZmcmVlX3BhZ2VzKTsNCj4gICAgICAgICAgICAgICAgIGNvbnRpbnVlOw0KPiAt
DQo+ICtjdWxsX21sb2NrZWQ6DQo+ICsgICAgICAgICAgICAgICAgaWYgKFBhZ2VTd2FwQ2Fj
aGUocGFnZSkpDQo+ICsgICAgICAgICAgICAgICAgICAgICAgICB0cnlfdG9fZnJlZV9zd2Fw
KHBhZ2UpOw0KPiArICAgICAgICAgICAgICAgIHVubG9ja19wYWdlKHBhZ2UpOw0KPiArICAg
ICAgICAgICAgICAgIGxpc3RfYWRkKCZwYWdlLT5scnUsICZyZXRfcGFnZXMpOw0KPiArICAg
ICAgICAgICAgICAgIGNvbnRpbnVlOw0KPiAgYWN0aXZhdGVfbG9ja2VkOg0KPiAgICAgICAg
ICAgICAgICAgLyogTm90IGEgY2FuZGlkYXRlIGZvciBzd2FwcGluZywgc28gcmVjbGFpbSBz
d2FwIHNwYWNlLiAqLw0KPiAgICAgICAgICAgICAgICAgaWYgKFBhZ2VTd2FwQ2FjaGUocGFn
ZSkgJiYgKG1lbV9jZ3JvdXBfc3dhcF9mdWxsKHBhZ2UpIHx8DQo+IA0KPiANCj4gDQo+IFJl
Z2FyZHMsDQo+IFBhbmthag0KPiANCj4gDQo+IEZyb206IEtpcmlsbCBUa2hhaSA8a3RraGFp
QHZpcnR1b3p6by5jb20+DQo+IFNlbnQ6IDE0IE1hcmNoIDIwMTkgMTQ6NTU6MzQNCj4gVG86
IFBhbmthaiBTdXJ5YXdhbnNoaTsgTWljaGFsIEhvY2tvDQo+IENjOiBsaW51eC1rZXJuZWxA
dmdlci5rZXJuZWwub3JnOyBtaW5jaGFuQGtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFJl
OiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xhaW0gdW5ldmljdGFibGUgcGFnZXMNCj4g
DQo+IA0KPiBPbiAxNC4wMy4yMDE5IDExOjUyLCBQYW5rYWogU3VyeWF3YW5zaGkgd3JvdGU6
DQo+Pg0KPj4gSSBhbSB1c2luZyBrZXJuZWwgdmVyc2lvbiA0LjE0LjY1IChvbiBBbmRyb2lk
IHBpZSBbQVJNXSkuDQo+Pg0KPj4gTm8gYWRkaXRpb25hbCBwYXRjaGVzIGFwcGxpZWQgb24g
dG9wIG9mIHZhbmlsbGEuKENvcmUgTU0pLg0KPj4NCj4+IElmICBJIGNoYW5nZSBpbiB0aGUg
dm1zY2FuLmMgYXMgYmVsb3cgcGF0Y2gsIGl0IHdpbGwgd29yay4NCj4gDQo+IFNvcnJ5LCBi
dXQgNC4xNC42NSBkb2VzIG5vdCBoYXZlIGJyYWNlcyBhcm91bmQgdHJ5bG9ja19wYWdlKCks
DQo+IGxpa2UgaW4geW91ciBwYXRjaCBiZWxvdy4NCj4gDQo+IFNlZSAgICAgaHR0cHM6Ly9n
aXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvc3RhYmxlL2xpbnV4Lmdp
dC90cmVlL21tL3Ztc2Nhbi5jP2g9djQuMTQuNjUNCj4gDQo+IFsuLi5dDQo+IA0KPj4+IGRp
ZmYgLS1naXQgYS9tbS92bXNjYW4uYyBiL21tL3Ztc2Nhbi5jDQo+Pj4gaW5kZXggYmU1NmUy
ZS4uMmU1MWVkYyAxMDA2NDQNCj4+PiAtLS0gYS9tbS92bXNjYW4uYw0KPj4+ICsrKyBiL21t
L3Ztc2Nhbi5jDQo+Pj4gQEAgLTk5MCwxNSArOTkwLDE3IEBAIHN0YXRpYyB1bnNpZ25lZCBs
b25nIHNocmlua19wYWdlX2xpc3Qoc3RydWN0IGxpc3RfaGVhZCAqcGFnZV9saXN0LA0KPj4+
ICAgICAgICAgICAgICAgICAgcGFnZSA9IGxydV90b19wYWdlKHBhZ2VfbGlzdCk7DQo+Pj4g
ICAgICAgICAgICAgICAgICBsaXN0X2RlbCgmcGFnZS0+bHJ1KTsNCj4+Pg0KPj4+ICAgICAg
ICAgICAgICAgICBpZiAoIXRyeWxvY2tfcGFnZShwYWdlKSkgew0KPj4+ICAgICAgICAgICAg
ICAgICAgICAgICAgICBnb3RvIGtlZXA7DQo+Pj4gICAgICAgICAgICAgICAgIH0NCj4gDQo+
ICoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKiogZUlu
Zm9jaGlwcyBCdXNpbmVzcyBEaXNjbGFpbWVyOiBUaGlzIGUtbWFpbCBtZXNzYWdlIGFuZCBh
bGwgYXR0YWNobWVudHMgdHJhbnNtaXR0ZWQgd2l0aCBpdCBhcmUgaW50ZW5kZWQgc29sZWx5
IGZvciB0aGUgdXNlIG9mIHRoZSBhZGRyZXNzZWUgYW5kIG1heSBjb250YWluIGxlZ2FsbHkg
cHJpdmlsZWdlZCBhbmQgY29uZmlkZW50aWFsIGluZm9ybWF0aW9uLiBJZiB0aGUgcmVhZGVy
IG9mIHRoaXMgbWVzc2FnZSBpcyBub3QgdGhlIGludGVuZGVkIHJlY2lwaWVudCwgb3IgYW4g
ZW1wbG95ZWUgb3IgYWdlbnQgcmVzcG9uc2libGUgZm9yIGRlbGl2ZXJpbmcgdGhpcyBtZXNz
YWdlIHRvIHRoZSBpbnRlbmRlZCByZWNpcGllbnQsIHlvdSBhcmUgaGVyZWJ5IG5vdGlmaWVk
IHRoYXQgYW55IGRpc3NlbWluYXRpb24sIGRpc3RyaWJ1dGlvbiwgY29weWluZywgb3Igb3Ro
ZXIgdXNlIG9mIHRoaXMgbWVzc2FnZSBvciBpdHMgYXR0YWNobWVudHMgaXMgc3RyaWN0bHkg
cHJvaGliaXRlZC4gSWYgeW91IGhhdmUgcmVjZWl2ZWQgdGhpcyBtZXNzYWdlIGluIGVycm9y
LCBwbGVhc2Ugbm90aWZ5IHRoZSBzZW5kZXIgaW1tZWRpYXRlbHkgYnkgcmVwbHlpbmcgdG8g
dGhpcyBtZXNzYWdlIGFuZCBwbGVhc2UgZGVsZXRlIGl0IGZyb20geW91ciBjb21wdXRlci4g
QW55IHZpZXdzIGV4cHJlc3NlZCBpbiB0aGlzIG1lc3NhZ2UgYXJlIHRob3NlIG9mIHRoZSBp
bmRpdmlkdWFsIHNlbmRlciB1bmxlc3Mgb3RoZXJ3aXNlIHN0YXRlZC4gQ29tcGFueSBoYXMg
dGFrZW4gZW5vdWdoIHByZWNhdXRpb25zIHRvIHByZXZlbnQgdGhlIHNwcmVhZCBvZiB2aXJ1
c2VzLiBIb3dldmVyIHRoZSBjb21wYW55IGFjY2VwdHMgbm8gbGlhYmlsaXR5IGZvciBhbnkg
ZGFtYWdlIGNhdXNlZCBieSBhbnkgdmlydXMgdHJhbnNtaXR0ZWQgYnkgdGhpcyBlbWFpbC4g
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KPiAN
Cg0K

