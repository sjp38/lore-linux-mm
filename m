Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 45DD86B00FD
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 18:36:26 -0400 (EDT)
Date: Wed, 18 Apr 2012 15:36:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: Use scnprintf instead of sprintf
Message-Id: <20120418153623.9582dffa.akpm@linux-foundation.org>
In-Reply-To: <1334729756-10212-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <20120416161354.b967790c.akpm@linux-foundation.org>
	<1334729756-10212-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On Wed, 18 Apr 2012 11:45:56 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This make sure we don't overflow.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 519d370..0ccf934 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5269,14 +5269,14 @@ static void mem_cgroup_destroy(struct cgroup *cont)
>  }
>  
>  #ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> -static char *mem_fmt(char *buf, unsigned long n)
> +static char *mem_fmt(char *buf, int size, unsigned long hsize)
>  {
> -	if (n >= (1UL << 30))
> -		sprintf(buf, "%luGB", n >> 30);
> -	else if (n >= (1UL << 20))
> -		sprintf(buf, "%luMB", n >> 20);
> +	if (hsize >= (1UL << 30))
> +		scnprintf(buf, size, "%luGB", hsize >> 30);
> +	else if (hsize >= (1UL << 20))
> +		scnprintf(buf, size, "%luMB", hsize >> 20);
>  	else
> -		sprintf(buf, "%luKB", n >> 10);
> +		scnprintf(buf, size, "%luKB", hsize >> 10);
>  	return buf;
>  }

We could use snprintf() here too but it doesn't seem to matter either
way.  I guess we _should_ use snprintf as it causes less surprise.

--- a/mm/memcontrol.c~hugetlbfs-add-memcg-control-files-for-hugetlbfs-use-scnprintf-instead-of-sprintf-fix
+++ a/mm/memcontrol.c
@@ -4037,7 +4037,7 @@ static ssize_t mem_cgroup_read(struct cg
 		BUG();
 	}
 
-	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
+	len = snprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
 	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
 }
 /*
@@ -5199,11 +5199,11 @@ static void mem_cgroup_destroy(struct cg
 static char *mem_fmt(char *buf, int size, unsigned long hsize)
 {
 	if (hsize >= (1UL << 30))
-		scnprintf(buf, size, "%luGB", hsize >> 30);
+		snprintf(buf, size, "%luGB", hsize >> 30);
 	else if (hsize >= (1UL << 20))
-		scnprintf(buf, size, "%luMB", hsize >> 20);
+		snprintf(buf, size, "%luMB", hsize >> 20);
 	else
-		scnprintf(buf, size, "%luKB", hsize >> 10);
+		snprintf(buf, size, "%luKB", hsize >> 10);
 	return buf;
 }
 

It is regrettable that your mem_fmt() exists, especially within
memcontrol.c - it is quite a generic thing.  Can't we use
lib/string_helpers.c:string_get_size()?  Or if not, modify
string_get_size() so it is usable here?

Speaking of which,

From: Andrew Morton <akpm@linux-foundation.org>
Subject: lib/string_helpers.c: make arrays static

Moving these arrays into static storage shrinks the kernel a bit:

   text    data     bss     dec     hex filename
    723     112      64     899     383 lib/string_helpers.o
    516     272      64     852     354 lib/string_helpers.o

Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/string_helpers.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN lib/string_helpers.c~lib-string_helpersc-make-arrays-static lib/string_helpers.c
--- a/lib/string_helpers.c~lib-string_helpersc-make-arrays-static
+++ a/lib/string_helpers.c
@@ -23,15 +23,15 @@
 int string_get_size(u64 size, const enum string_size_units units,
 		    char *buf, int len)
 {
-	const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
+	static const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
 				   "EB", "ZB", "YB", NULL};
-	const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
+	static const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
 				 "EiB", "ZiB", "YiB", NULL };
-	const char **units_str[] = {
+	static const char **units_str[] = {
 		[STRING_UNITS_10] =  units_10,
 		[STRING_UNITS_2] = units_2,
 	};
-	const unsigned int divisor[] = {
+	static const unsigned int divisor[] = {
 		[STRING_UNITS_10] = 1000,
 		[STRING_UNITS_2] = 1024,
 	};
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
