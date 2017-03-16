Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B96776B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:51:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so92507285pga.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:51:13 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b61si5378268plc.304.2017.03.16.06.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 06:51:12 -0700 (PDT)
Date: Thu, 16 Mar 2017 21:51:22 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170316135122.GF13054@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <20170316073403.GE1661@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170316073403.GE1661@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, Mar 16, 2017 at 03:34:03PM +0800, Aaron Lu wrote:
> On Wed, Mar 15, 2017 at 05:28:43PM +0100, Michal Hocko wrote:
> ... ...
> > After all the amount of the work to be done is the same we just risk
> > more lock contentions, unexpected CPU usage etc.
> 
> I start to realize this is a good question.
> 
> I guess max_active=4 produced almost the best result(max_active=8 is
> only slightly better) is due to the test box is a 4 node machine and
> therefore, there are 4 zone->lock to contend(let's ignore those tiny
> zones only available in node 0).
> 
> I'm going to test on a EP to see if max_active=2 will suffice to produce
> a good enough result. If so, the proper default number should be the
> number of nodes.

Here are test results on 2 nodes EP with 128GiB memory, test size 100GiB.

max_active           time
vanilla              2.971s +-3.8%
2                    1.699s +-13.7%
4                    1.616s +-3.1%
8                    1.642s +-0.9%

So 4 gives best result but 2 is probably good enough.

If the size each worker deals with is changed from 1G to 2G:

max_active           time
2                    1.605s +-1.7%
4                    1.639s +-1.2%
8                    1.626s +-1.8%

Considering that we are mostly improving for memory intensive apps, the
default setting should probably be: max_active = node_number with each
worker freeing 2G memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
