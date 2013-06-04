Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 910336B0078
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 05:09:32 -0400 (EDT)
Message-ID: <51ADAF00.9020605@parallels.com>
Date: Tue, 4 Jun 2013 13:10:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 19/34] drivers: convert shrinkers to new count/scan
 API
References: <1368994047-5997-1-git-send-email-glommer@openvz.org> <1368994047-5997-20-git-send-email-glommer@openvz.org> <20130603200331.GK2291@google.com>
In-Reply-To: <20130603200331.GK2291@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <koverstreet@google.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On 06/04/2013 12:03 AM, Kent Overstreet wrote:
>> -	for (i = 0; nr && i < c->bucket_cache_used; i++) {
>> > +	for (i = 0; i < c->bucket_cache_used; i++) {
> This is a bug (but it's probably more my fault for writing it too subtly
> in the first place): previously, we broke out of the loop when nr
> reached 0 (and we'd freed all the objects we were asked to).
> 
> After your change it doesn't break out of the loop until trying to free
> _everything_ - which will break things very badly since this causes us
> to free our reserve. You'll want a if (freed >= nr) break; like you
> added in the previous loop.
> 
> (The reserve should be documented here too though, I'll write a patch
> for that...)
> 
Just please notice the following:

This came up a while ago in a discussion in the fs conversion patch.
But nr to scan is the number of objects we as you to *scan*, not to free.

previously, you would only decrement nr when you could free the object.

Since I need to fix the problem anyway here of looping through all of
them, this is what I intend to write:

        for (i = 0; (nr--) && i < c->bucket_cache_used; i++) {
		[ ... ]
        }

This won't test "freed" at all. Shout if you disagree.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
