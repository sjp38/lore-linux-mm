Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 556386B005D
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:36:12 -0500 (EST)
Date: Fri, 21 Dec 2012 13:36:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm,ksm: use new hashtable implementation
Message-Id: <20121221133610.bb516813.akpm@linux-foundation.org>
In-Reply-To: <1356112012-24584-1-git-send-email-sasha.levin@oracle.com>
References: <1356112012-24584-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

On Fri, 21 Dec 2012 12:46:50 -0500
Sasha Levin <sasha.levin@oracle.com> wrote:

> Switch ksm to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in the ksm module.

hm, include/linux/hashtable.h:hash_min() is rather dangerous - it
returns different values depending on the size of the first argument. 
So if the calling code mixes up its ints and longs (and boy we do that
a lot), the result will work on 32-bit and fail on 64-bit.

Also, is there ever likely to be a situation where the first arg to
hash_min() is *not* a pointer?  Perhaps it would be better to concede
to reality: rename `key' to `ptr' and remove all those typcasts you
just added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
