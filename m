Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3B9440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 15:43:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g14so101608208pgu.9
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 12:43:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g14si7552249plk.15.2017.07.14.12.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 12:43:53 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
Date: Fri, 14 Jul 2017 12:43:51 -0700
MIME-Version: 1.0
In-Reply-To: <20170713201620.GB1979@redhat.com>
Content-Type: multipart/mixed;
	boundary="------------3EF90A38EBF18CB462281659"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

--------------3EF90A38EBF18CB462281659
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 7/13/17 1:16 PM, Jerome Glisse wrote:

> ...
>

Hi Jerome,

I have hit another kind of hang. Briefly, if a not yet allocated page 
faults on CPU during migration to device memory, any subsequent 
migration will fail for such page. Such a situation can trigger if a CPU 
page fault happens just immediately after migrate_vma() starts unmapping 
pages to migrate.

Please find attached a reproducer based on the sample driver. In the 
hmm_test() function, an HMM_DMIRROR_MIGRATE request is triggered from a 
separate thread for not yet allocated pages (coming from malloc). In the 
same time, a HMM_DMIRROR_READ request is made for the same pages. This 
results in a sporadic app-side hang, because random number of pages 
never migrate to device memory.

Note that if the pages are touched (initialized with data) prior to 
that, everything works as expected: all HMM_DMIRROR_READ and 
HMM_DMIRROR_MIGRATE requests eventually succeed. See comments in the 
hmm_test() function.

Thanks!

-- 
Evgeny Baskakov
NVIDIA


--------------3EF90A38EBF18CB462281659
Content-Type: application/x-gzip;
	name="sanity_rmem004_repeated_faults_threaded_notallocated.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="sanity_rmem004_repeated_faults_threaded_notallocated.tgz"

H4sIAA4eaVkAA+097XLbOJLzd/QUiBMnlCJbkuPYdVacWW8iJ7q1ZZdsXzaXSbFoEpI4lkgt
STnWzvje5/7fG+yLXTcAkgBISrLjZOZu2FWxJHw00I3uRuOjkdDy3GhuBhM6aTa3zYBOqRVR
xxxYs3EUmtEooJYDvz0/ssZj38bMxg93g2azufvyJWGfO/yzubXNPwWQ1ovWi60tKNfcIs2t
lztbOz+Ql3ds514wCyMrgK7Q6yH15pdWeGVd+dfZclBsMFiAR9CRfP4fgfA+4385c8fOZjha
sY1l4996scPHH77vbLdg/He3Xu7+QJrflHIBf/LxH9o22RiSjZMXZOMDjDDZ6G7Cv7HrzW6I
KhybNhlNJmZEw8gcBNaEfvGDK0jc8LWCZGPK5abye1NXwjK4l/7nicGCNphabxfp/9bOFth8
of8vmi+3SfNFa2fnZan/3wMatQqpkTf+dB64w1FEtsAakz51yHsrIl3P3oRsLHE+ckMyDfwh
jDiBr4OAUhL6g+iLFdA2mfszYlseCajjhlHgXs4iStyIWJ7T8ANEMPEddzDHtJnn0IBEI0oi
GkxC4g/Yj3e9C/KOejSwxuR0djl2bXLk2tQLKbFCxDDFxHAEfbucsxqH2Icz0Qdy6ANiK3J9
r02oC/kBuaZBCL/JFrSBGLCSwFknfkAMoBF6HhB/ivWq0N05GYOIJ1WLyE+pdIjrMcQjfwoU
jQAl0PjFBVN6SckspIPZuI4ooDD50D1/f3JxTg56H8mHg37/oHf+sQ2Fo5EPufSaclTuZDp2
ATPQFVheNBfdP+7037yHKgd/7R51zz8iBYfd817n7IwcnvTJATk96J9331wcHfTJ6UX/9OSs
s0nIGcVuUUSwgMUDQDbxgY0OjSx3HMaEH8ygb0G4R/79X/8d/Ot/JjBOMAhQ4dUvQ/blLzDk
QPSm7U9eQ4VG5bFDB65HiQmtmWcnF/03nUrlsevZ45kD1SyoE0Sbo9dSWuROqJpCg8Dz1aSB
7UVjNSmMHNfPJnlRJm3sXuppgesN1bSZB6PqaOVo9Mtkmlc31BLnYWMysbxsajSf0pzCYFD0
fkKq69s6lWIyzUGcYdui5uahDRYcM9KctRxLPlqrJGM4pFHkOkaVGMbUdcyoKrAYZx/PTJ5Z
rabFjy+OzkHC+52Dt5235nH3Xf/gvEOaBfn4AZlp7sHfIe28/5G0dtLUg6Puu55xUycW9sK4
qZLnoLdkg7SqVfKUGP9lGJDDfkJPkKkg1SACxETa6I0bmf4V2SfNdpwJ42lezgZSAepdJ7kz
L3SHHijf1BpSM3T/SZXKWvbIHUTZvLHvDXmBCcwn7aRbIDgzO2JelB3dkNoQP9pSr8dI8bXv
OqyMC1OzydC43sA3ML1a+bVCANwBMZIOVglPRAhoNAu8Nvt9y/7KdODw+d7AMM/emKcH7zrm
Wfc/O9W2VA4JgoKDQSjjB/ZKhZAoKAOcVyiupjX4eLQrtwltCVHI8Awp8ljJ1CBaGC5DGao6
2WhVZQoZSpZ2q0gAVnJmk8kc2QyuzRDUmwaGPgrwJ+5LDtdFS1Bo4zXoANANcj9FpeAZnOEo
IdB43Cq2h3gWtWWPrAD4GY080LxPL7Y+gyAU9yFhFTdIKkeqWQkAHsks0pShJRCG3hRMWTQw
4n7UCQ6fnyZU62St4dBr5vM5EzcI/GBN5skAWQJTnyfhODH7bz/066QpCmK/48KvIFXq7UB0
AAwv2HxozPZnY4eAu8mQIjcIG0PiBC5MysRYD6s/e2v1hHWijVzS5REqkAYcETZ2iYRiNpge
d+Hgjf2QxjRl2IEdAIyqPUA0YHYGNDC9yzkYXRk/zyA1/hm3InrOEzdeeygRIXn1SjE+TOYz
iOTW6BfT8nzPANUPIy53NT5Qag95t+LGC3vHqdWqsq6tJsGPRDuLpMDodKpkPcTB3uTFycZr
sj522NCb5mDm2aZZJ5wMgTAVhMTQVBVJEAzcF5MKr1YnkqF7/VrhLaslqN8nE7YCMoSGxGMl
yXhccp/0Lo6OViYwxssYXs2hcDllsYgk4icnIgpIxg8tI+aHMnyNRlKA6zuSPrGmRrNO8kSw
HtfKh9P+yTmf63/j3z/0u+edJZWOD07N0373P9B/+I39Ouid9D4en1ycLam50UrtDhRKhyWl
Zp8hPDzoHnXexoMk8C0eJ2QCyGDeEMWsSVtm6GCFIppXM/RhhOTbDPen0dew/u58vyfTF3Cc
UfCHZndW0rkyGoLdz8GRwbVnYiI4Ar6K0SSr2s5HaaDJrVUNzV/iTpNW+rnk121wF1f3s3g9
pVSbkAondUIn4CFoHYPxSeRHpUXpsJC3+zAAqmrUc2QrkY5F70l3PtWAcAnJysya8VNruN4S
e1/mpe/M5alaOEEmZpLalH3Gcyb0Ru2yyx2qROpYIjSemlrHV1UCMoFvbBlosPUBGvU6eX98
bL497vb7J32m1DBr8ZZTgSZfRu6YEgMxPIWVEVtDo/p1ur3zfrWatokqCqVAGVmTWvPIGOah
16qsp6rCXPtjYBS0w0ip3eAgK2m1Ku/ZxmvLcYC3YoiEpq994mwl685nUPS9dWePYDnSvFmf
1sm1NZ7RZJ6Pl5+o/YcXvTfn3ZMeWgDTPOr2OvgN1oW1G4ky3MYwXFyxAYOYBMadgV9t4oL7
iePREHM4dAl05/lzV7NLbHkVBZ/cz+QRDIaWW2S59ta3nSqsPIAIECJOyieg5TMZgju77sBC
ZUpt3DISBBYZ1ZQ+l5EB/YCvqklLZSWe7qWMS6D5Skm91YZRHWejdqOtnthKVJXl425PU8gb
3YOca57rzav5Tzd7c2VtJLxSSYvyHO164vHkQKFrurCW2tUQbcIdynNbskq3kIdgdNhHzA+x
h2NGhH8JP+FuB98KOfvc1h1uxcYUlUeGunxzIttd1ltzCowW+hY7eaRBJFQpJm6UVF1l+gki
HH7eE7X3QHRn9ZgI+OXUM02xMmLOztfaSiqq2S2hn8ja1ApgEqLjNbJH1mCecUGh/kmdtdii
12USsh3QLJ2g+7VcSdNoheA9Evk+TIPenGNeSo7qTqtqqi1JUwUUU5bgJJuuhFESSYnBZrMA
jB/fK8KU1MpxkyYPKHGfP1e3A1B63M+bzMqCsZ4BqWBTzEiff5lGwBdXTJgKSyFtu/lvO+0s
XjHRZ9GmHs09Mdvx8qQp6GayOkDSs3iADYL/EvEKumS1g4ZMr544Cxv5vUy7d5t8o+OQLm2s
KddUqMiKvt712GrYAR7KGU9j24HTAa4w68J+G2DBuSGvPtVdlzp5GldanYjUBVnggMh4lfrC
vUAnhPsgj2IfRGsIATRC0z69JdYfnD0ZrnVnoS5C2TovKVErEYbKmHg1OQOT9l8VQiBBG9s8
YjRKBhY4RQ6YE1aXCRWxInR1xjdLqJCU9k6EqN9u012XxdJ2F4uCwN1kEDMzdWZl9qWSig5o
s5qhwPa9yPVmVKsbS/wvvusZsrg/FW1pzOCiyvw4gy0P8rtU4PNK2Tmjl5FDyuzZcgFky7Ec
/EWjlk4Kmf7eVQjzKfkmcrgKUfEPRRqVHXNl2TVxhwEYumUrL1EMF1/ia+xmacurZG2VisrC
hZU4scK1VYxY7LKtuLYqErIFkhWfkq0kXEzQVS0oWLDluvnNBY54wnv/zu44h/s55UrdB/Sc
YxkRnw/hP2u7pgv9aKEB8l7YH9MN1affh/f25W7kHhAvdPhVolZ0/L+Xb41IQTCV3XMmB8U+
qjZImvle4qJqovR1ruoSDzVRHNmZjSnNK7RwfbGgyvN95v8DJbk8q7YXec1ChB7Ccc6ZfMDt
kLq7KmOVWSeGpT51MvcUNMmaXXEakvlV5PMwNj3QtJTn8wiiV/W3c8Tt0X7Big4hu2zIcXLC
xMuRGlh34haY6UqbYT+rS02Z1gsEXabZvl2WIu3QYjVOqd/gb4FHn6MJX+nUy1lFli7uy72s
HcIDWzyVZwg5Cqq021wqmn+wtcz/Y6X+A2g0wvdU54peXL6JIjx0dqy59LLI4gsI6r2w2Ceb
zDw8ZNVPCxddOEn9Sq0yO3RboaZ6SHtbxgj8rvBQ9/8XxQItvv/f3G01X7L7/63d3d2t3Rd4
/3+3Vcb/fBco7/+X9/8f9v4/l6jD2DIwzGwd5npDglYDBAXH1HNw34aGIU/EYuCr4GaDPxuO
GB/YdU3EdkUDj47FFdBN0rHsEa8Vjth10ZF1TYnvARkzz8ahZJeEknA1o0oi6wrbt5gggUOG
YwyORbzHJWZXKwTpdP8xowR3JCYUS2FH+ezJEMi1LQ/RJdYQiAGjKXDFDESawHZ4TshJRJw+
mBrqz0JyTIHnc3JseTBLTqgX1VF4QL5AlUZ0DC4uiOMc/rpe6Do0lmEenSeYglRAURi4axjL
+JqsOHyzUGhtZDI6MvgZTi0beQX1YnS85iYXcrTyX0TSs1Ds/WAjIMqsdIicVbHBqtQeMSW3
rmDWB1EA38C1mTIy/oFeWoTe2CPLG1Im7+TN6UWM3CJjH6TfCl0YXFnhkukFLA0se6ezYOpD
LyAH+kNvaGC78PPaClxkpu07lN0KFtwSDGJU+qxrJJwFQkdxWIC9MCRggWDYk6sZ2F1rHPpY
ZzCehSOCqomG4XI2ZGrRqDx2B2DDBsy3Pu+cnZuH/YPjzoeT/t/M90ngQm7mA4W45ISzZMNe
csNZ7hqPEoe0SMlM+uT74DxfiuIQi0zS2lLuJqOiievT6U3kDNSYLqWXVXFTtQgGDi/DglMK
ykAeuJntFS/nt1e8Bw74cq5dr0BdShhrqABqyZ7ZwlKc/3n71yrI+3bL+HnbTijj+/GcKNzW
29nO57Ij0EtVH+guensFfCEgoQ+JcADLzhx8yDjctVPxxmj/nNebiuj+ErgRvftB0j3PkO5K
+t1pvxPxf7ijtDY6ZXFfRSdZTm7/8o7TNHQwB+qkg58RwQxavE/BFQiLyUZ2tS2O9lfE0rQr
ypT814vDw07f7HU+sNvtBvQLHH8jqO7nmanHLLsIwdn7g36nGAM3TItRHHaPGIZBERJmjB7H
JaRZjB1tCFvFrBS6Prp1iu88J6lYFdYUjj/hQXjSUHhAcTimdJre8vQY96gHSzfSqOW6NOgP
/d6L2BLuDffa/7ka+9YDvv+y29L2f+BPc6vc//ke8PhR49L1GuGo8rjymJzhzgMsk+zAnUa4
AsKBbgQUP9jiD5dNSjgmLpe4KSLWFIz7NHDhO6ASy1G0T7BqqoRzz64Ek4nvyPNKBX5DpUsq
J5LffmMhvaQFFcjGgGxGk6l5bdYqCdqmyNEjUysT6xc/2H9iWF+uyNrPT7b2939ek05Afl4j
v7JDBvLzk9btGmng6rjBcYbVCrVHvtIThg7Xm0/Yt8rkygMC9FaJLfJJs2KPhsGU0FiOsj20
R8iDnZ3tbFYlnDk+ARUT/YKCM+Ae+Y0MQS/JM7nJZ5CKRD4T9DzZuX12Hzt8L/3nK8CV21j1
/S9J/5vNl+X7X98D7jX+wcxb3fqvMP5bO9nxL/f/vwswk7PZUMWgdOj+NHAv/dffhVvSxuLz
v9b2Dug8f/+xtbO72yL4Cthus9T/7wHl+V95/vctzv8Yw9LTPntE7SvOnS+USUp8QRu3WeYT
PL+Z8MMwWHWItQNPQGz8DA7WIIPAB/5H8THM4mesVnhCK+e5rfRlsGTP5s1J781Fv9/pncdX
qMyDHg+iSQt1e93z7sFRUiI5BFGORrK5SXYPH7/qds7Mbq/X6Uv14gw5CV9vggS0NUli8qIT
MbaBaS0wsum+k9hz4tmiei2tUk127uOrs74X0ZuI7/4vfgsmZxORpeO6JHKdeopy5vELUUnA
OBbRL97SoestLYULxPjA4ZuFLC8KTsGTZoPnWMEw59GcgkgEJWJB43VN/d3Oi2nRquwTowBX
Fbol6ohbw4/UInjfK8NT+c5YXM00cfVuXvr+GOpOpmBtTdBIM/xiTeO71YVI2XDWCXsjRL/z
l3vxnLVqtPSyS8MzhEw3iN6hjPSle+VLbrVmMOFo591z1Qt+9b1XQcxGlpjcLnzDG7BiOItj
AORC2RiAIs4oMQEZFFJMwMoMUO/eipukyWMTOGnzJvAWx/o4vk6K3h9LYjNLGhGX02xd40Vd
6bPeg6VRAHoLq0UFPFhEwFfcGx7f/eJwjkRKF4S/7nJwbGAL7gfHyA2UnHWn+qB3hMX94JWk
Jfe28EqqKj3nka2Xd5NYjgbMvonIrkTlnvxhCW82MVUbnvckXOaFCpNnivsYSdCehulTjg/0
edGUqM0mIjkfTSYYcPm7dW6dXCmxe9JrA9ITL+Cd18naU1AwsCSxvCVhcWfn6Hf33jEhymOf
QJh3/BifjUruWbUgEi0HcyaMo4Bd7ufN5BU7mRmLq0ihccsLR+xtTHelotKEjBNKDl0rYMnz
M9TZbOW67LRBf2bC0IPIdFFOg8lyXMPUYmebr6ohJNalH+jv+TUa5MLDe3QUfegRrs/wXh5O
VJdjH5dSPon3Y1g+t3Gw1n1zerEZozjxbMyFqc/Fi40CH2UeOeWrsyk+5IUHNKKKEo8qzpXj
qTp+ZS3zxpI8qTNR5e5L3stKCDUDg1xq1afsaSPx/sfnaio+BW8WsYb5W77kCltRFkyQpupC
Rn9dWNjzO4lxyOqVPD9KVmzVYEa5ypJ3UPIr2TlOmJyfeF2Co2lvgS3dAaFsn+N0hGvsFm4I
8K9bXErYuAewir4uHnOBS6DYI8eJdYuFii/IYTG+WRhZtoppQlhtRXE3nWfhva3M2gKheMrM
kr61Rw5xz5M9PTuHiSDZ7hRsAGnyg9Tf4JtDKZYEzkd0nuz/4IkoDcZzCZt02TRFkPEW7/IG
ixAWOT51uVso8eFhJ5p829r6CpPe+ureKqF4RXZcY8qqs//pwdlZ5+2yuR8k5K3vPYv4xikq
l5iQ0ZCzbQThviZyAmZqGtBrdrU5sVxhjAyqgXgFdBbyosockUwA+g0r5W1MLeqMbbJYwB/8
YgVDmMLkO5CQcv3pc44niF6CiKJPGb6ZXOKF5DXc40vVhu/kYYE1zvCM3xY7pFD3qZn4HwXO
qfSYQ1334FBUcqpAkYLdunZeC+TVft7eXW5ZbQrSZDWesXKNI++7ckOZ3zSWC62wgHv06JGC
hfCnV9nmc44EL5BcvYWhD2IH2rBwwyAlg60z2LpiOfo70MXmsG9OU/xNSVauhauDkyzDANee
bkHEE5HrYRWf1yDrvIPIqZ/IWqfDnr04+RskMS1rgkFiNj9RolyNfZDzn6+4/6FEACxqY0n8
34vmbkuP/9ve3SnP/74HlOd/5fnfNzv/w3Ay9bpgErdl0+Q+oTFSYuLEMeAkiYmrsn6cdmNB
4WFdm6QbiWA1kDvgc8Bj0eJBYi3xcLEoBHcYA8hE1Bri44XlYMPM/zSBVxfVeC/zArqB24IX
fzdlXzwN+ioukQmgygnD4hk5Z5IiI/iHx4Otijbifq38GMfp/Pgjf35ZSmBLV+l3vJMvJdnZ
pILgHkeO9Pg9Go6n/MVNexKSRo10uEjgeGsBkVy28D83wk2WOGoyFhBJOOg1kwz5v7rS12U/
/mh2Tz70jWfvn8Hq9KbZzI2pYOcWuTjYS/06klYuEsb+fCzCXdXxbOXiSR7Sk677Fwpzeee/
hBJKKKGEEkoooYQSSiihhBJKKKGEEkoooYQSSiihhBJKKKGEEkoooYQSSiihhBJKKOF3g/8F
Gmi+8wCgAAA=
--------------3EF90A38EBF18CB462281659--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
