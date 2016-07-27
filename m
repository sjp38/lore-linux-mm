Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BEC86B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 12:44:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w207so2609075oiw.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:44:01 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id d28si6109917otd.269.2016.07.27.09.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 09:44:00 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id l9so1832845oih.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:44:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1650204.9z6KOJWgNh@storm>
References: <bug-64121-27@https.bugzilla.kernel.org/> <b4aff3a2-cc22-c68c-cafc-96db332f86c3@intra2net.com>
 <b3219832-110d-2b74-5ba9-694ab30589f0@suse.cz> <1650204.9z6KOJWgNh@storm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jul 2016 09:44:00 -0700
Message-ID: <CA+55aFw-g0T6c3Oza8UDssdCiEhMQZHDixsBqCXU4funLsumFg@mail.gmail.com>
Subject: Re: Re: [Bug 64121] New: [BISECTED] "mm" performance regression
 updating from 3.2 to 3.3
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed, Jul 27, 2016 at 2:18 AM, Thomas Jarosch
<thomas.jarosch@intra2net.com> wrote:
>
> Yesterday another busy mail server showed the same problem during backup
> creation. This time I knew about slabtop and could see that the
> ext4_inode_cache occupied about 393MB of the 776MB total low memory.

Honestly, we're never going to really fix the problem with low memory
on 32-bit kernels. PAE is a horrible hardware hack, and it was always
very fragile. It's only going to get more fragile as fewer and fewer
people are running 32-bit environments in any big way.

Quite frankly, 32GB of RAM on a 32-bit kernel is so crazy as to be
ludicrous, and nobody sane will support that. Run 32-bit user space by
all means, but the kernel needs to be 64-bit if you have more than 8GB
of RAM.

Realistically, PAE is "workable" up to approximately 4GB of physical
RAM, where the exact limit depends on your workload.

So if the bulk of your memory use is just user-space processes, then
you can more comfortably run with more memory (so 8GB or even 16GB of
RAM might work quite well).

And as mentioned, things are getting worse, and not better. We cared
much more deeply about PAE back in the 2.x timeframe. Back then, it
was a primary target, and you would find people who cared. These days,
it simply isn't. These days, the technical solution to PAE literally
is "just run a 64-bit kernel".

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
