Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 302546B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:18:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so31946948lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:18:32 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 76si2837029wmr.124.2016.07.13.05.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 05:18:31 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id f65so26375067wmi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:18:30 -0700 (PDT)
Date: Wed, 13 Jul 2016 14:18:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
Message-ID: <20160713121828.GI28723@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160713112126.GH28723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Wed 13-07-16 13:21:26, Michal Hocko wrote:
> On Tue 12-07-16 16:56:32, Matthias Dahl wrote:
[...]
> > If that support is baked into the Fedora provided kernel that is. If
> > you could give me a few hints or pointers, how to properly do a allocator
> > trace point and get some decent data out of it, that would be nice.
> 
> You need to have a kernel with CONFIG_TRACEPOINTS and then enable them
> via debugfs. You are interested in kmalloc tracepoint and specify a size
> as a filter to only see those that are really interesting. I haven't
> checked your slabinfo yet - hope to get to it later today.

The largest contributors seem to be
$ zcat slabinfo.txt.gz | awk '{printf "%s %d\n" , $1, $6*$15}' | head_and_tail.sh 133 | paste-with-diff.sh | sort -n -k3
			initial	diff [#pages]
radix_tree_node 	3444    2592
debug_objects_cache     388     46159
file_lock_ctx   	114     138570
buffer_head     	5616    238704
kmalloc-256     	328     573164
bio-3   		24      1118984

So it seems we are accumulating bios and 256B objects. Buffer heads as
well but so much. Having over 4G worth of bios sounds really suspicious.
Note that they pin pages to be written so this might be consuming the
rest of the unaccounted memory! So the main question is why those bios
do not get dispatched or finished.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
