Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4906B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:11:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so8344675wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:11:05 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id z9si3655942wmz.5.2016.07.15.00.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 00:11:03 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Jul 2016 09:11:02 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage) with check/repair/sync
In-Reply-To: <9074e82f-bf52-011e-8bd7-5731d2b0dcaa@I-love.SAKURA.ne.jp>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
 <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
 <20160713134717.GL28723@dhcp22.suse.cz>
 <9074e82f-bf52-011e-8bd7-5731d2b0dcaa@I-love.SAKURA.ne.jp>
Message-ID: <005574d77d3f5dbc2643044a1e2468dc@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

Hello...

I am rather persistent (stubborn?) when it comes to tracking down bugs,
if somehow possible... and it seems it paid off... somewhat. ;-)

So I did quite a lot more further tests and came up with something very
interesting: As long as the RAID is in sync (as-in: sync_action=idle),
I can not for the life of me trigger this issue -- the used memory
still explodes to most of the RAM but it oscillates back and forth.

I did very stupid things to stress the machine while dd was running as
usual on the dm-crypt device. I opened a second dd instance with the
same parameters on the dm-crypt device. I wrote a simple program that
allocated random amounts of memory (up to 10 GiB), memset them and after
a random amount of time released it again -- in a continuous loop. I
put heavy network stress on the machine... whatever I could think of.

No matter what, the issue did not trigger. And I repeated said tests
quite a few times over extended time periods (usually an hour or so).
Everything worked beautifully with nice speeds and no noticeable system
slow-downs/lag.

As soon as I issued a "check" to sync_action of the RAID device, it was
just a matter of a second until the OOM killer kicked in and all hell
broke loose again. And basically all of my tests where done while the
RAID device was syncing -- due to a very unfortunate series of events.

I tried to repeat that same test with an external (USB3) connected disk
with a Linux s/w RAID10 over two partitions... but unfortunately that
behaves rather differently. I assume it is because it is connected
through USB and not SATA. While doing those tests on my RAID10 with the
4 internal SATA3 disks, you can see w/ free that the "used memory" does
explode to most of the RAM and then oscillates back and forth. With the
same test on the external disk through, that does not happen at all. The
used memory stays pretty much constant and only the buffers vary... but
most of the memory is still free in that case.

I hope my persistence on the matter is not annoying and finally leads us
somewhere where the real issue hides.

Any suggestions, opinions and ideas are greatly appreciated as I have
pretty much exhausted mine at this time.

Last but not least: I switched my testing to a OpenSuSE Tumbleweed Live
system (x86_64 w/ kernel 4.6.3) as Rawhide w/ 4.7.0rcX behaves rather
strangely and unstable at times.

Thanks,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
