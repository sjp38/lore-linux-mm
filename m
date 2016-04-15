Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C71DF6B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:10:36 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id h185so204561478vkg.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:10:36 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id s66si36691347qgs.69.2016.04.15.07.10.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 07:10:35 -0700 (PDT)
Subject: Re: linux-next crash during very early boot
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <20160414013546.GA9198@js1304-P5Q-DELUXE>
References: <3689.1460593786@turing-police.cc.vt.edu>
 <20160414013546.GA9198@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1460729433_2433P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Apr 2016 10:10:33 -0400
Message-ID: <58269.1460729433@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1460729433_2433P
Content-Type: text/plain; charset=us-ascii

On Thu, 14 Apr 2016 10:35:47 +0900, Joonsoo Kim said:
> On Wed, Apr 13, 2016 at 08:29:46PM -0400, Valdis Kletnieks wrote:
> > I'm seeing my laptop crash/wedge up/something during very early
> > boot - before it can write anything to the console.  Nothing in pstore,
> > need to hold down the power button for 6 seconds and reboot.
> >
> > git bisect points at:
> >
> > commit 7a6bacb133752beacb76775797fd550417e9d3a2
> > Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Date:   Thu Apr 7 13:59:39 2016 +1000
> >
> >     mm/slab: factor out kmem_cache_node initialization code
> >
> >     It can be reused on other place, so factor out it.  Following patch wil
l
> >     use it.
> >
> >
> > Not sure what the problem is - the logic *looks* ok at first read.  The
> > patch *does* remove a spin_lock_irq() - but I find it difficult to
> > believe that with it gone, my laptop is able to hit the race condition
> > the spinlock protects against *every single boot*.
> >
> > The only other thing I see is that n->free_limit used to be assigned
> > every time, and now it's only assigned at initial creation.
>
> Hello,
>
> My fault. It should be assgined every time. Please test below patch.
> I will send it with proper SOB after you confirm the problem disappear.
> Thanks for report and analysis!

Following up - I verified that it was your patch series and not a bad bisect
by starting with a clean next-20160413 and reverting that series - and the
resulting kernel boots fine.

Will take a closer look at your fix patch and figure out what's still changed
afterwards - there's obviously some small semantic change that actually
matters, but we're not spotting it yet...

--==_Exmh_1460729433_2433P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVxD2WQdmEQWDXROgAQLtfhAAsVE1c//k3n7hQuBCdmloQxuUoG/YvvWW
SKeL/vnlUpL2fKqcBdeFOMNzA8ohZ9G0ON7X3MtWDoMsbOAB1O1EnzoS75xuevW9
J0mnBk5Exog2Txn3s/cjgyxqcAfHoW/VT9q/jt40qr8uFxcFV8H9dnycnURIkCzW
yTMMvwNT8TmRlwx0yTuIdA8SSOVzxj3BoOkdurf7AWMBd7oFEvYcj7mDcfieqQsI
ZpS41p0l64TN7C/ahdXB9H91ogCFzLuaqFfL29GnuXdbzfNY/j3QhuD+7nCj/lT9
bPW4fr+rI/gLTFGLBtjAJv9cQopgs/OpQjpG/eWAHE9v6kn5YV88h1HcQHTyJoLS
UYmuVN1o8LouJ35kTJIZXfKq7tzZDh3itQAnH9lLla9sXvMrQlech7B0Cssa2vvn
Qwu6E/N/tR76YHgY7JNvIH1sjFK+eagVkDSY7rqbkWhJf8EGeVNfOqdtT/YvOPuB
CxhIMbZ6/GHeHI5TIVE0RxSnnjGLlSY1MqCz/cxx1HOwgG1KtGU9HWq7t3536ujS
lljpsDc9QmqS004QNgnreZJytV59fbyvW6I0upoZJiDHek8hJTI33JTnIjBfKkus
32OQsmwj3rXUyY81bSLXr4pUbDE13JVKRqzRvBFtiCl+yiaNVCUAUrAjF3gB5S+b
ZQMhuKbVtJ0=
=L2vc
-----END PGP SIGNATURE-----

--==_Exmh_1460729433_2433P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
