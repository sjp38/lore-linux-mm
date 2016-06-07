Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0753A6B0253
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:02:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so237810220pad.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:02:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id o90si33932228pfa.151.2016.06.07.02.02.06
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 02:02:06 -0700 (PDT)
From: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Subject: RE: mm: pages are not freed from lru_add_pvecs after process
 termination
Date: Tue, 7 Jun 2016 09:02:02 +0000
Message-ID: <D6EDEBF1F91015459DB866AC4EE162CC023F84C9@IRSMSX103.ger.corp.intel.com>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com> <20160511075313.GE16677@dhcp22.suse.cz>
In-Reply-To: <20160511075313.GE16677@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Wed 05-11-16 09:53:00, Michal Hocko wrote:
> Yes I think this makes sense. The only case where it would be suboptimal
> is when the pagevec was already full and then we just created a single
> page pvec to drain it. This can be handled better though by:
>
> diff --git a/mm/swap.c b/mm/swap.c
> index 95916142fc46..3fe4f180e8bf 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
> 	struct pagevec *pvec =3D &get_cpu_var(lru_add_pvec);
>=20
> 	get_page(page);
>-	if (!pagevec_space(pvec))
>+	if (!pagevec_add(pvec, page) || PageCompound(page))
> 		__pagevec_lru_add(pvec);
>-	pagevec_add(pvec, page);
> 	put_cpu_var(lru_add_pvec);
>}

It's been a while, but I am back with some results.
For 2M i 4K pages I wrote simple app which mmaps and unmaps a lot of memory=
 (60GB/288CPU) in parallel and does it ten times to get rid of some os/thre=
ading overhead.
Then I created an app which mixes pages in sort of pseudo random random way=
.
I executed those 10 times under "time" (once with THP=3Don and once with TH=
P=3Doff) command and calculated sum, min, max, avg of sys, real, user time =
which was necessary due to significant bias in results.

In overall it seems that this change has no negative impact on performance:
4K  THP=3Don,off -> no significant change
2M  THP=3Don,off -> it might be a tiny bit slower, but still close to measu=
rement error
MIX THP=3Don,off -> no significant change

If you have any concerns about test correctness please let me know.
Below I added test applications and test results.

Thanks,
Lukas
=09
------------------------------------------------------------------

//compile with: gcc bench.c -o bench_2M -fopenmp
//compile with: gcc -D SMALL_PAGES bench.c -o bench_4K -fopenmp
#include <stdio.h>
#include <sys/mman.h>
#include <omp.h>

#define MAP_HUGE_SHIFT  26
#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)

#ifndef SMALL_PAGES
#define PAGE_SIZE (1024*1024*2)
#define MAP_PARAM (MAP_HUGE_2MB)
#else
#define PAGE_SIZE (1024*4)
#define MAP_PARAM (0)
#endif

void main() {
        size_t size =3D ((60 * 1000 * 1000) / 288) * 1000; // 60GBs of memo=
ry 288 CPUs
        #pragma omp parallel
        {
        unsigned int k;
        for (k =3D 0; k < 10; k++) {
                void *p =3D mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PR=
IVATE | MAP_ANON | MAP_PARAM, -1, 0);
                        if (p !=3D MAP_FAILED) {
                                char *cp =3D (char*)p;
                                size_t i;
                                for (i =3D 0; i < size / PAGE_SIZE; i++) {
                                        *cp =3D 0;
                                        cp +=3D PAGE_SIZE;
                                }
                                munmap(p, size);
                        }
        }
        }
}

//compile with: gcc bench_mixed.c -o bench_mixed -fopenmp
#include <stdio.h>
#include <sys/mman.h>
#include <omp.h>
#define SMALL_PAGE (1024*4)
#define HUGE_PAGE (1024*4)
#define MAP_HUGE_SHIFT  26
#define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
void main() {
        size_t size =3D ((60 * 1000 * 1000) / 288) * 1000; // 60GBs of memo=
ry 288 CPUs
        #pragma omp parallel
        {
        unsigned int k, MAP_PARAM =3D 0;
        unsigned int PAGE_SIZE =3D SMALL_PAGE;
        for (k =3D 0; k < 10; k++) {
                if ((k + omp_get_thread_num()) % 2) {
                        MAP_PARAM =3D MAP_HUGE_2MB;
                        PAGE_SIZE =3D HUGE_PAGE;
                }
                void *p =3D mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PR=
IVATE | MAP_ANON | MAP_PARAM, -1, 0);
                        if (p !=3D MAP_FAILED) {
                                char *cp =3D (char*)p;
                                size_t i;
                                for (i =3D 0; i < size / PAGE_SIZE; i++) {
                                        *cp =3D 0;
                                        cp +=3D PAGE_SIZE;
                                }
                                munmap(p, size);
                        }
        }
        }
}



*******************************

######### 4K THP=3DON############
###real  unpatched   patched###
sum =3D 428.737s sum =3D 421.339s
min =3D 41.187s min =3D 41.492s
max =3D 44.948s max =3D 42.822s
avg =3D 42.874s avg =3D 42.134s

###user  unpatched   patched###
sum =3D 145.241s sum =3D 147.283s
min =3D 13.760s min =3D 14.418s
max =3D 15.532s max =3D 15.201s
avg =3D 14.524s avg =3D 14.728s

###sys  unpatched   patched###
sum =3D 4882.708s sum =3D 5020.581s
min =3D 441.922s min =3D 490.516s
max =3D 535.294s max =3D 532.137s
avg =3D 488.271s avg =3D 502.058s

######### 4K THP=3DOFF###########
###real  unpatched   patched###
sum =3D 2149.288s sum =3D 2144.336s
min =3D 214.589s min =3D 212.642s
max =3D 215.937s max =3D 215.579s
avg =3D 214.929s avg =3D 214.434s

###user  unpatched   patched###
sum =3D 858.659s sum =3D 858.166s
min =3D 81.655s min =3D 82.084s
max =3D 87.790s max =3D 88.649s
avg =3D 85.866s avg =3D 85.817s

###sys  unpatched   patched###
sum =3D 32357.867s sum =3D 31126.183s
min =3D 2952.685s min =3D 2783.157s
max =3D 3442.004s max =3D 3406.730s
avg =3D 3235.787s avg =3D 3112.618s

*******************************

######### 2K THP=3DON############
###real  unpatched   patched###
sum =3D 497.032s sum =3D 500.115s
min =3D 48.840s min =3D 49.529s
max =3D 50.731s max =3D 50.698s
avg =3D 49.703s avg =3D 50.011s

###real  unpatched   patched###
sum =3D 56.536s sum =3D 59.286s
min =3D 5.021s min =3D 5.014s
max =3D 7.465s max =3D 8.865s
avg =3D 5.654s avg =3D 5.929s

###real  unpatched   patched###
sum =3D 4187.996s sum =3D 4450.088s
min =3D 391.334s min =3D 406.223s
max =3D 453.087s max =3D 530.787s
avg =3D 418.800s avg =3D 445.009s

######### 2K THP=3DOFF###########
###real  unpatched   patched###
sum =3D 54.698s sum =3D 53.383s
min =3D 5.196s min =3D 4.802s
max =3D 5.707s max =3D 5.639s
avg =3D 5.470s avg =3D 5.338s

###real  unpatched   patched###
sum =3D 55.567s sum =3D 60.980s
min =3D 4.625s min =3D 4.745s
max =3D 6.860s max =3D 6.727s
avg =3D 5.557s avg =3D 6.098s

###real  unpatched   patched###
sum =3D 215.267s sum =3D 215.924s
min =3D 21.194s min =3D 20.139s
max =3D 21.946s max =3D 22.724s
avg =3D 21.527s avg =3D 21.592s

*******************************

#######MIXED THP=3DOFF###########
###real  unpatched   patched###
sum =3D 2146.501s sum =3D 2145.591s
min =3D 211.727s min =3D 211.757s
max =3D 216.011s max =3D 215.340s
avg =3D 214.650s avg =3D 214.559s

###user  unpatched   patched###
sum =3D 895.243s sum =3D 909.778s
min =3D 87.540s min =3D 87.862s
max =3D 91.340s max =3D 94.337s
avg =3D 89.524s avg =3D 90.978s

###sys  unpatched   patched###
sum =3D 31916.377s sum =3D 30965.023s
min =3D 2988.592s min =3D 2878.047s
max =3D 3581.066s max =3D 3270.986s
avg =3D 3191.638s avg =3D 3096.502s
#######MIXED THP=3DON###########
###real  unpatched   patched###
sum =3D 440.068s sum =3D 431.539s
min =3D 41.317s min =3D 41.860s
max =3D 58.752s max =3D 47.080s
avg =3D 44.007s avg =3D 43.154s

###user  unpatched   patched###
sum =3D 153.703s sum =3D 151.004s
min =3D 14.395s min =3D 14.210s
max =3D 16.778s max =3D 16.484s
avg =3D 15.370s avg =3D 15.100s

###sys  unpatched   patched###
sum =3D 4945.824s sum =3D 4957.661s
min =3D 459.862s min =3D 469.810s
max =3D 514.161s max =3D 526.257s
avg =3D 494.582s avg =3D 495.766s


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
