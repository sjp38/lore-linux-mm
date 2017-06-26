Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E10F6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:28:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f49so27257622wrf.5
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 22:28:12 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id o63si10682466wme.171.2017.06.25.22.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 22:28:10 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id c11so136521400wrc.3
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 22:28:10 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
Date: Mon, 26 Jun 2017 08:28:07 +0300
MIME-Version: 1.0
In-Reply-To: <20170623113837.GM5308@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

IGBPI?I1I? 23/06/2017 02:38 I 1/4 I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> this means that the highmem is not dirtyable and so only 20% of the free
> lowmem (+ page cache in that region) is considered and writers might
> get throttled quite early (this might be a really low number when the
> lowmem is congested already). Do you see the same problem when enabling
> highmem_is_dirtyable = 1?
> 

Excellent advice! :)
Indeed, setting highmem_is_dirtyable=1 completely eliminates the issue!

Is that something that should be =1 by default, i.e. should I notify the 
Ubuntu developers that the defaults they ship aren't appropriate,
or is it something that only 16+ GB RAM memory owners should adjust in 
their local configuration?

Thanks a lot!
Results of 2 test runs, with highmem_is_dirtyable=0 and 1:

1) echo 0 > highmem_is_dirtyable:
-----------------------------------------------------------------------------
16.04.2 LTS (Xenial Xerus), 4.8.0-56-generic, i386, RAM=16292548
-----------------------------------------------------------------------------
Copying /lib to 1: 18.60
Copying 1 to 2: 6.09
Copying 2 to 3: 6.04
Copying 3 to 4: 7.04
Copying 4 to 5: 6.28
Copying 5 to 6: 5.03
Copying 6 to 7: 6.50
Copying 7 to 8: 4.82
Copying 8 to 9: 5.49
Copying 9 to 10: 5.88
Copying 10 to 11: 5.09
Copying 11 to 12: 5.70
Copying 12 to 13: 5.19
Copying 13 to 14: 4.55
Copying 14 to 15: 4.69
Copying 15 to 16: 4.76
Copying 16 to 17: 5.38
Copying 17 to 18: 4.59
Copying 18 to 19: 4.26
Copying 19 to 20: 4.47
Copying 20 to 21: 4.32
Copying 21 to 22: 4.33
Copying 22 to 23: 5.55
Copying 23 to 24: 4.73
Copying 24 to 25: 4.80
Copying 25 to 26: 5.06
Copying 26 to 27: 16.84
Copying 27 to 28: 5.28
Copying 28 to 29: 5.45
Copying 29 to 30: 12.35
Copying 30 to 31: 5.90
Copying 31 to 32: 4.90
Copying 32 to 33: 4.76
Copying 33 to 34: 4.37
Copying 34 to 35: 5.82
Copying 35 to 36: 4.55
Copying 36 to 37: 8.80
Copying 37 to 38: 5.07
Copying 38 to 39: 5.69
Copying 39 to 40: 4.88
Copying 40 to 41: 5.26
Copying 41 to 42: 4.69
Copying 42 to 43: 5.10
Copying 43 to 44: 4.79
Copying 44 to 45: 4.54
Copying 45 to 46: 7.46
Copying 46 to 47: 5.54
Copying 47 to 48: 4.86
Copying 48 to 49: 6.12
Copying 49 to 50: 5.37
Copying 50 to 51: 7.63
Copying 51 to 52: 6.37
Copying 52 to 53: 5.81
...

2) echo 1 > highmem_is_dirtyable:
-----------------------------------------------------------------------------
16.04.2 LTS (Xenial Xerus), 4.8.0-56-generic, i386, RAM=16292548
-----------------------------------------------------------------------------
Copying /lib to 1: 21.47
Copying 1 to 2: 5.54
Copying 2 to 3: 6.63
Copying 3 to 4: 4.69
Copying 4 to 5: 5.38
Copying 5 to 6: 8.50
Copying 6 to 7: 9.34
Copying 7 to 8: 8.78
Copying 8 to 9: 9.48
Copying 9 to 10: 10.89
Copying 10 to 11: 10.52
Copying 11 to 12: 11.28
Copying 12 to 13: 14.70
Copying 13 to 14: 17.71
Copying 14 to 15: 52.43
Copying 15 to 16: 92.52
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
