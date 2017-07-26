From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH] mm/slub: fix a deadlock due to incomplete patching
 of cpusets_enabled()
Date: Wed, 26 Jul 2017 12:02:17 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
References: <20170726165022.10326-1-dmitriyz@waymo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726165022.10326-1-dmitriyz@waymo.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dima Zavin <dmitriyz@waymo.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>
List-Id: linux-mm.kvack.org

On Wed, 26 Jul 2017, Dima Zavin wrote:

> The fix is to cache the value that's returned by cpusets_enabled() at the
> top of the loop, and only operate on the seqlock (both begin and retry) if
> it was true.

I think the proper fix would be to ensure that the calls to
read_mems_allowed_{begin,retry} cannot cause the deadlock. Otherwise you
have to fix this in multiple places.

Maybe read_mems_allowed_* can do some form of synchronization or *_retry
can implictly rely on the results of cpusets_enabled() by *_begin?
