Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 767E76B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 05:41:26 -0500 (EST)
Received: by labge10 with SMTP id ge10so24632419lab.12
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 02:41:25 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id t7si5804345lbz.63.2015.02.24.02.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 02:41:24 -0800 (PST)
Message-ID: <54EC5552.5080202@yandex-team.ru>
Date: Tue, 24 Feb 2015 13:41:22 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
References: <20150219171934.20458.30175.stgit@buzz> <20150220150731.e79cd30dc6ecf3c7a3f5caa3@linux-foundation.org> <20150220235012.GS29656@ZenIV.linux.org.uk>
In-Reply-To: <20150220235012.GS29656@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On 21.02.2015 02:50, Al Viro wrote:
> On Fri, Feb 20, 2015 at 03:07:31PM -0800, Andrew Morton wrote:
>
>> - It no longer "acquires a reference".  All it does is to acquire an rwsem.
>>
>> - What the heck is a "passive reference" anyway?  It appears to be
>>    the situation where we increment s_count without incrementing s_active.
>
> Reference to struct super_block that guarantees only that its memory won't
> be freed until we drop it.
>
>>    After your patch, this superblock state no longer exists(?),
>
> Yes, it does.  The _only_ reason why that patch isn't outright bogus is that
> we do only down_read_trylock() on ->s_umount - try to pull off the same thing
> with down_read() and you'll get a nasty race.

I don't get this. What the problem with down_read(sb->s_umount)?

For grab_super_passive()/trylock_super() caller guarantees memory
wouldn't be freed and we check tsb activeness after grabbing shared
lock. And while we hold that lock it'll stay active.

It have to use down_read_trylock() just because it works in in atomic
context when writeback calls it. No?

Check for activeness actually is a quite confusing.
It seems checking for MS_BORN and MS_ACTIVE should be enough:

  bool trylock_super(struct super_block *sb)
  {
         if (down_read_trylock(&sb->s_umount)) {
-               if (!hlist_unhashed(&sb->s_instances) &&
-                   sb->s_root && (sb->s_flags & MS_BORN))
+               if ((sb->s_flags & MS_BORN) && (sb->s_flags & MS_ACTIVE))
                         return true;
                 up_read(&sb->s_umount);
         }

> Take a look at e.g.
> get_super().  Or user_get_super().  Or iterate_supers()/iterate_supers_type(),
> where we don't return such references, but pass them to a callback instead.
> In all those cases we end up with passive reference taken, ->s_umount
> taken shared (_NOT_ with trylock) and fs checked for being still alive.
> Then it's guaranteed to stay alive until we do drop_super().
>
> I agree that the name blows, BTW - something like try_get_super() might have
> been more descriptive, but with this change it actually becomes a bad name
> as well, since after it we need a different way to release the obtained ref;
> not the same as after get_super().  Your variant might be OK, but I'd
> probably make it trylock_super(), to match the verb-object order of the
> rest of identifiers in that area...
>
>> so
>>    perhaps the entire "passive reference" concept and any references to
>>    it can be expunged from the kernel.
>
> Nope.
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
