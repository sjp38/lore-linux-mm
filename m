Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35124C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 02:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5B8820854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 02:39:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="obDt0O3T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5B8820854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C2018E0003; Wed, 13 Mar 2019 22:39:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7720E8E0001; Wed, 13 Mar 2019 22:39:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6615F8E0003; Wed, 13 Mar 2019 22:39:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 236758E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:39:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w4so4494927pgl.19
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:39:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=WrV/l3y03S7xRIJhtjzGGZQ2l0CIcACK9FVzXe701Bc=;
        b=NThzH17PbxwItmIK6UAQmMCvcI2rI15R+F5p8gDKwGUML5+synMWVed/EcTrPV5ozi
         arj64Zo/vVfgkXqZf4E3qnVD/nJt7rt5oDRtMqUs7KOD6DUE/HIGVmGalAeSZBjp2zDB
         vjMFYLIABy7r6sE7gG2k9HPAOrK7ROX/dBZUTfPYYyWZZwMtzHL8ke91/rReinFczBCt
         bwWrOrGzAPu4WTZBDu7uTUrIZsCP9dI2DJb4jHv+pGmJKGgs1N7kf36fFdTb7zOO9k87
         W+GcBnCeEpL5Kl6SxniFMtq+M4tf77DYX81KS2R13RCVEMl9ZYuxfWYmjwzF8e1rrxn9
         0Tgw==
X-Gm-Message-State: APjAAAWJlw5rAIiE4mS+wtS/bjqn1ULiJhCOzgd/rF80GYbOrA3M1Vm2
	6e7K3IrPwSPz7PQ+eIRmHR6Ph5c7CxA0GTGCAx8myDw6TH1AtCYYgwe31re8krSHJ2XDey4LWTt
	TJ2F3aN5FbGdtp1H9O0ynLn+4fYFoiAsUsGNDXjUT4/B7CZfdaDMMpg2ALpWuA0/6IQ==
X-Received: by 2002:a65:50c8:: with SMTP id s8mr10374365pgp.308.1552531158652;
        Wed, 13 Mar 2019 19:39:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk9JQjCYYMIRwudHh2CrleZT9GgEk9uf5pLasaBhcDhn20ZDGs4wkqeTmjK7etUtU2QZiL
X-Received: by 2002:a65:50c8:: with SMTP id s8mr10374307pgp.308.1552531157293;
        Wed, 13 Mar 2019 19:39:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552531157; cv=none;
        d=google.com; s=arc-20160816;
        b=YLwjtUFoAlfP7+tO9jAuduuXUQr4TYEBttK/IsCrnNyyxJ46lN7vOpw7E0pRzfoBFN
         NLRGwxM5/SBqJwp+4jDXksGsEcXlyhFLQmf0saVG8JpId2lr7A2XHsJfRmJq3N36ZKD9
         FEJVEefcPaHop4wwWU2q8kyMK6HFK6jGiHMa5sPvjHKPQsbq9MUDCHdMcvQVNp2QY2bb
         QO6juZyKxBXMZKw95wQW849anHq+oarL93WsSihn/mIiBNDy1ro8L6npf+MW39nx/bmB
         4R5HWTRM18IUcgmlJO/7Q/BPOaABK280YIYm9wX+2Eck/rV0TxUII+GMzyBnBMRm9fkE
         XyEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=WrV/l3y03S7xRIJhtjzGGZQ2l0CIcACK9FVzXe701Bc=;
        b=L8QyySgc5elVsUmKf3pHOtwH1zfd8rJXxUeweFYG3PCD8EkiCsJBQmhCOgcK2uAzPa
         9COG+Nlx1ZRm2S2/M8h3LmK3X3SsfIc8s9jtxB6OUji0YVcNzmHvsh0vCAG5RwGxhHQo
         zEoHjP4ZOnGcAll2kBvfc5kj1nojWnemq/1TSJWPDeh33zUxV9tK/xagnbc0UCkQJ9Hw
         E4FkkAR24uqrTKurUtymPzgKi0yFa9u5DSxU5HtoJ5vRGGs2E05ekc7jVM7fij/Fkk3v
         zU6Nn7i1dzYa11eE+yAVHKcvk2+Ai5t5qYD9IlXkDBvYqoGOb7wa7TFhkbcGNkpGmjTH
         F7mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (dns failure for signature) header.i=@infradead.org header.s=bombadil.20170209 header.b=obDt0O3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c24si11726325pfo.11.2019.03.13.19.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 19:39:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=temperror (dns failure for signature) header.i=@infradead.org header.s=bombadil.20170209 header.b=obDt0O3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:To:From:Date:Sender:Reply-To:Cc:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WrV/l3y03S7xRIJhtjzGGZQ2l0CIcACK9FVzXe701Bc=; b=obDt0O3TpgUPyGNDmJ9iJqqEB
	Ssi+k202lcjhiehZWxX6ofSRKAMJy7HQVlD1/2RP5fR7Q7CL/TD1bvRuRyq7rczg1chAeFMJNxAlp
	bv4J67NCThJ58mI6SQex2asFuz54u3NkLQuRvk6UC55pgP440mcY4M6CTPnBvby6v4fYMaVHg9nX4
	jHgIfYuc6REF//krysmYpyhtl1KElDNpxNnQdoPg9rQrDALsOqKD67dlLYZeQ325LsaGp2kuLjYEk
	ewCWLYjdGa9bFQ7kbQiy+0UDBlnUTflaAyZ6kSby8rTsWBqu0ezgj1XEPVdQdD434VA8aO/UInC3o
	hCCzu11Tg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h4GH0-0000H1-AO; Thu, 14 Mar 2019 02:39:10 +0000
Date: Wed, 13 Mar 2019 19:39:10 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Laurent Dufour <ldufour@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
Message-ID: <20190314023910.GL19508@bombadil.infradead.org>
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
 <20190313210603.fguuxu3otj5epk3q@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313210603.fguuxu3otj5epk3q@linux-r8p5>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 02:06:03PM -0700, Davidlohr Bueso wrote:
> On Wed, 13 Mar 2019, Laurent Dufour wrote:
> > If this is not too late and if there is still place available, I would
> > like to attend the MM track and propose a topic about using the XArray
> > to replace the VMA's RB tree and list.
> > 
> > Using the XArray in place of the VMA's tree and list seems to be a first
> > step to the long way of removing/replacing the mmap_sem.
> 
> So threaded (not as in threads of execution) rbtrees are another
> alternative to deal with the two data structure approach we currently
> have. Having O(1) rb_prev/next() calls allows us to basically get rid of
> the vma list at the cost of an extra check for each node we visit on
> the way down when inserting.

It's probably worth listing the advantages of the Maple Tree over the
rbtree.

 - Shallower tree.  A 1000-entry rbtree is 10 levels deep.  A 1000-entry
   Maple Tree is 5 levels deep (I did a more detailed analysis in an
   earlier email thread with Laurent and I can present it if needed).
 - O(1) prev/next
 - Lookups under the RCU lock

There're some second-order effects too; by using externally allocated
nodes, we avoid disturbing other VMAs when inserting/deleting, and we
avoid bouncing cachelines around (eg the VMA which happens to end up
at the head of the tree is accessed by every lookup in the tree because
it's on the way to every other node).

