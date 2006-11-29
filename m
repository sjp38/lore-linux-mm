Message-ID: <456D1FDA.4040201@yahoo.com.au>
Date: Wed, 29 Nov 2006 16:51:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com> <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com> <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org> <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> The _only_ valid reason to use typedefs ever is because it's a type that 
> depends on some configuration option (where "architecture" is obviously 
> the biggest config option of all).

I don't see why pagetable types are conceptually different from slab here.
kmem_cache_t might just be an integer (index into an array, or something).

> If the type has the same name regardless of config options, it should 
> never be a typedef. And "struct kmem_cache" obviously doesn't change names 
> just because of config options (it may change some of the _members_ it 
> contains, but that's a totally different thing, and has no bearing 
> what-so-ever on whether you should use a typedef).

pagetable types can all have the same struct name. Should we do a script
to change them?

> So typedefs are good for
> 
>  - "u8"/"u16"/"u32"/"u64" kind of things, where the underlying types 
>    really are potentially different on different architectures.
> 
>  - "sector_t"-like things which may be 32-bit or 64-bit depending on some 
>    CONFIG_LBD option or other.
> 
>  - as a special case, "sparse" actually makes bitwise typedefs have real 
>    meaning as types, so if you are using sparse to distinguish between a 
>    little-endian 16-bit entity or a big-endian 16-bit entity, the typedef 
>    there is actually important and has real meaning to sparse (without the 
>    typedef, each bitwise type declaration would be strictly a _different_ 
>    type from another bitwise type declaration that otherwise looks the 
>    same).
> 
> But typedefs are NOT good for:
> 
>  - trying to avoid typing a few characters:
> 
> 	"kmem_cache_t" is strictly _worse_ than "struct kmem_cache", not 
> 	just because it causes declaration issues. It also hides the fact 
> 	that the thing really is a structure (and hiding the fact that 
> 	it's a pointer is a shooting offense: things like "voidptr_t" 
> 	should not be allowed at all)

Umm, but it's not a pointer, is it? And I don't see any problem with making
it opaque to callers who don't and shouldn't care. I seem to remember you
making this argument for the pagetable types as well...

I think slab.c should use struct kmem_cache, but I don't see why this script
needs to change over all callers. At least, not in the name of solving
dependency issues?!?

>  - incorrect "portability". 
> 
> 	the POSIX "socklen_t" was not only a really bad way to write
> 	"int", it actually caused a lot of NON-portability, and made some 
> 	people think it should be "size_t" or something equally broken.
> 
> The one excuse for typedefs in the "typing" sense can be complicated 
> function pointer types. Some function pointers are just too easy to screw 
> up, and using a
> 
> 	typedef (*myfn_t)(int, ...);
> 
> can be preferable over forcing people to write that really complex kind of 
> type out every time. But that shouldn't be overused either (but we use it 
> for things like "readdir_t", for example, for exactly this reason).

Sure. I'm not arguing against it because it is too hard to type. I just
don't think it is solving any problem, and it seems to be rather pointless
churn.

If it was presented strictly as a cleanup patch then I would have less to
argue about, I guess: I'm not exactly pro-typedef for these situations, and
I'm definitely anti-typedef when you are accessing struct members.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
