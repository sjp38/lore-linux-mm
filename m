Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5E5046B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:17:00 -0400 (EDT)
Date: Thu, 4 Apr 2013 17:16:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: System freezes when RAM is full (64-bit)
Message-ID: <20130404151658.GJ29911@dhcp22.suse.cz>
References: <5159DCA0.3080408@gmail.com>
 <20130403121220.GA14388@dhcp22.suse.cz>
 <515CC8E6.3000402@gmail.com>
 <20130404070856.GB29911@dhcp22.suse.cz>
 <515D89BE.2040609@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515D89BE.2040609@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivan Danov <huhavel@gmail.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, 1162073@bugs.launchpad.net

On Thu 04-04-13 16:10:06, Ivan Danov wrote:
> Hi Michal,
> 
> Yes, I use swap partition (2GB), but I have applied some things for
> keeping the life of the SSD hard drive longer. All the things I have
> done are under point 3. at
> http://www.rileybrandt.com/2012/11/18/linux-ultrabook/.

OK, I guess I know what's going on here.
So you did set vm.swappiness=0 which (for some time) means that there is
almost no swapping going on (although you have plenty of swap as you are
mentioning above).
This shouldn't be a big deal normally but you are also backing your
/tmp on tmpfs which is in-memory filesystem. This means that if you
are writing to /tmp a lot then this content will fill up your memory
which is not swapped out until the memory reclaim is getting into real
troubles - most of the page cache is dropped by that time so your system
starts trashing.

I would encourage you to set swappiness to a more reasonable value (I
would use the default value which is 60). I understand that you are
concerned about your SSD lifetime but your user experience sounds like a
bigger priority ;)

> By system freezes, I mean that the desktop environment doesn't react
> on my input. Just sometimes the mouse is reacting very very choppy
> and slowly, but most of the times it is not reacting at all. In the
> attached file, I have the output of the script and the content of
> dmesg for all levels from warn to emerg, as well as my kernel config.

I haven't checked your attached data but you should get an overview from
Shmem line from /proc/meminfo which tells you how much shmem/tmpfs
memory you are using and grep "^Swap" /proc/meminfo will tell you more
about your swap usage.

> 
> Best,
> Ivan

HTH
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
